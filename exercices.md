Pure OTP Exercise

Create a todo list using only pure processes

1) Add a todo to a todo-list

```ex
TODO.add(%{ title: "study otp", completed: false })
%{ id: "md5-943jg4938j39", title: "study otp", completed: false,  created_at:"2018-10-02" }
```

2) List todos

```ex
TODO.list
[
  %{ id: "md5-943jg4938j39", title: "learn elixir", completed: false },
  %{ id: "md5-f0932jf934", title: "study otp", completed: false }
]
```

3) Mark todo as completed

```ex
TODO.complete("md5-943jg4938j39")
{ id: "md5-943jg4938j39", title: "study otp", completed: true, created_at: "2018-10-03", completed_at:"2018-10-03" }
```

4) Add validation to not allow duplicated todos titles

```ex
TODO.add(%{ title: "study otp", completed: false })
%{ id: "md5-943jg4938j39", title: "study otp", completed: false,  created_at:"2018-10-02" }
TODO.add(%{ title: "study otp", completed: false })
{ error: "task already created"}
```

5) Add validation to not allow completion on already completed tasks

```json
TODO.complete("md5-943jg4938j39")
{ id: "md5-943jg4938j39", title: "study otp", completed: true, created_at: "2018-10-03", completed_at:"2018-10-03" }
TODO.complete("md5-943jg4938j39")
{ error: "task already completed"}
```

6) Add Supervision to the Application

When the todo process crashes it will be restarted automatically

7) Tests
