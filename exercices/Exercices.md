Elixir Exercices

1) Create a plug server with a simple endpoint that returns 200 status code for all requests:

```
GET localhost/hello
```

```
200
hello word
```

2) Return json on the response

```
GET localhost:4000/hello
```

```json
200
{ "result": "hello world" }
```

3) Add a todo to a todo-list saved on an agent

```json
POST /todos
{ "title": "study otp", "completed": false }
```

```json
201
{ "id": "md5-943jg4938j39", "title": "study otp", "completed": false, "created_at":"2018-10-02" }
```

4) Show todo list

```json
GET /todos
```

```json
200
[
  { "id": "md5-943jg4938j39", "title": "learn elixir", "completed": false },
  { "id": "md5-f0932jf934", "title": "study otp", "completed": false }
]
```

5) Mark task as completed

``` json
PATCH /todos/md5-943jg4938j39
{ "completed": true }
```

```json
200
{ "id": "md5-943jg4938j39", "title": "study otp", "completed": true, "created_at":"2018-10-03", "completed_at":"2018-10-03" }
```

6) Add validation to not allow duplicated tasks titles

```json
# assuming 'study otp' already exists
POST /todos
{ "title": "study otp", "completed": false }
```
```json
409
{ "error": "task already created"}
```

7) Add validation to not allow completion on already completed tasks

```json
# assuming 'study otp' is already completed
POST /todos
{ "title": "study otp", "completed": true }
```
```json
400
{ "error": "task already completed"}
```

8) Unit & Integration tests

9) Refactor: Delegate the request handling to different otp processes with load balancing

10) Refactor: Use ecto instead of an agent to persist the TODO

11) Use Phoenix instead of pure Plug
