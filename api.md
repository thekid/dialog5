Albums
======

Create an album
---------------

```sh
$ curl -XPOST -v http://localhost:8080/api/albums/ -H'Content-type: text/json' -d '{ "title" : "Test Album", "description" : "This is the description text" }'
```

Response:
* 201: Created, `Location: http://localhost:8080/albums/test_album`
* 409: Album already exists

Get an album
------------

```sh
$ curl -XGET -v http://localhost:8080/api/albums/test_album
```

Response:
* 200: Found
* 404: Not found

```json
{
  "chapters": [],
  "createdAt": "Sun, 23 Dec 2012 15:02:43 +0100",
  "description": "This is the second test",
  "highlights": [],
  "name": "test_album",
  "title": "Test Album"
}
```

Change an album
---------------

```sh
$ curl -XPATCH -v http://localhost:8080/api/albums/test_album -H'Content-type: text/json' -d '{ "title" : "New title" }'
```

* 200: OK
* 404: Not found

```json
{
  "chapters": [],
  "createdAt": "Sun, 23 Dec 2012 15:25:09 +0100",
  "description": "This is the description text",
  "highlights": [],
  "name": "test_album",
  "title": "New title"
}
```

Delete an album
---------------

```sh
curl -XDELETE -v http://localhost:8080/api/albums/test_album 
```

Response:
* 204: Deleted
* 404: Not found
