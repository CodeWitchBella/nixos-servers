import fs from "node:fs/promises";
import p from "node:child_process";
import process from "node:process";

const check = JSON.parse(await fs.readFile("check.json", "utf-8"));
const images: {
  [key: string]: {
    repository: string;
    tag: string;
    digest: string;
    sha256: string;
    platform?: { [key: string]: string };
  };
} = JSON.parse(await fs.readFile("images.json", "utf-8"));
for (const image of check.images) {
  if (!image.result.has_update) {
    console.log(`${image.reference} is already up to date`);
    continue;
  }
  await update(image);
  await fs.writeFile("images.json", JSON.stringify(images, null, 2), "utf-8");
}

async function update(
  check: {
    in_use: boolean;
    parts: { repository: string; registry: string; tag: string };
    reference: string;
    result: {
      info: {
        current_version: string;
        new_tag: string;
        new_version: string;
        type: string;
        version_update_type: string;
      };
    };
  },
) {
  let spec = Object.values(images).find((img) =>
    img.repository === check.reference.split(":")[0]
  );
  if (!spec) {
    spec = {
      repository: check.reference.split(":")[0],
      tag: check.result.info.new_tag,
      digest: "",
      sha256: "",
    }
    images[spec?.repository.split("/").at(-1)] = spec
  }

  // get the new tag and digest for the correct platform
  const out = await p.spawnSync("podman", [
    "manifest",
    "inspect",
    `${check.parts.registry}/${check.parts.repository}:${check.result.info.new_tag}`,
  ], { encoding: "utf-8" });
  const update = JSON.parse(out.stdout);
  for (const manifest of update.manifests) {
    if (
      Object.entries(spec.platform || {}).every(([k, v]) =>
        manifest.platform[k] === v
      )
    ) {
      Object.assign(spec, {
        tag: check.result.info.new_tag,
        digest: manifest.digest,
        platform: manifest.platform,
      });
      break;
    }
  }
  console.log(`Updated ${check.reference} to ${spec.tag} (${spec.digest})`);

  // get the sha256 of the image
  await fs.rm("image.tgz", { force: true });
  const digestOut = await p.spawnSync("skopeo", [
    "copy",
    `docker://${check.parts.registry}/${check.parts.repository}@${spec.digest}`,
    `docker-archive:/${process.cwd()}/image.tgz`,
  ], { encoding: "utf-8" });
  if (digestOut.status !== 0) {
    console.error(digestOut);
    throw new Error("Failed to copy image");
  }
  const hash = await p.spawnSync("nix-hash", [
    "--base32",
    "--flat",
    "--type",
    "sha256",
    "image.tgz",
  ], { encoding: "utf-8" });
  await fs.rm("image.tgz");
  if (hash.status !== 0) {
    console.error(hash);
    throw new Error("Failed to hash image");
  }
  spec.sha256 = hash.stdout.trim();
  console.log(`Updated sha256 to ${spec.sha256}`);
}
