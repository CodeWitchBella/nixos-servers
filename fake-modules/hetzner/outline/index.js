// @ts-check

export default {
  async fetch(request, env) {
    const secret = "foobar"
    const { pathname, origin, searchParams } = new URL(request.url)

    // debug
    if (pathname.startsWith("/_info")) {
      return new Response("Hello world!")
    }

    // change attachment uploadUrl response
    if (pathname === "/api/attachments.create") {
      const resp = await fetch(request)
      const json = await resp.json()
      json.data.uploadUrl = origin + `/_upload?secret=${secret}`
      return new Response(JSON.stringify(json, null, 2), {
        headers: {
          "content-type": "application/json; charset=utf-8",
        },
      })
    }

    // handle multipart form upload from outline
    if (pathname === "/_upload") {
      // Check if the secret matches
      if (searchParams.get("secret") !== secret) {
        return new Response("Unauthorized", { status: 400 })
      }
      const formData = await request.formData()
      const file = formData.get("file")
      const key = formData.get("key")
      await env.OUTLINE_BUCKET.put(key, file.stream())
      return new Response(`Put ${key} successfully!`)
    }

    return fetch(request)
  },
}
