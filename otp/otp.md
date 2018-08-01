# Uma geladeira

Vamos modelar uma geladeira: nós podemos colocar e tirar comida dela.

```
defmodule Fridge do
  def start_link() do
    spawn_link __MODULE__, :loop, [[]]
  end

  def put(pid, food) do
    send pid, {:put, food}
  end

  def take(pid) do
    send pid, :take
  end

  def loop(foods) do
    receive do
      {:put, food} ->
        IO.puts "You put #{food} in your fridge."
        loop([food|foods])
      :take ->
        case foods do
          [h|t] -> 
            IO.puts "Take your #{h}"
            loop(t)
          [] ->
            IO.puts "Nothing to eat!"
            loop([])
        end
    end
  end
end
```

Para testar o código basta colar o módulo no REPL e usar:

```
pid = Fridge.start_link

Fridge.take pid # Nothing to eat!

Fridge.put pid, "Apple" # You put...
Fridge.put pid, "Banana" # You put...

Fridge.take pid # Take your ...
Fridge.take pid # Take your ...

Fridge.take pid # Nothing to eat!

```


O que não está muito legal é que a geladeira responde pelo próprio console usando `IO.puts/1`, e não respondendo ao cliente. O servidor só tem como responder ao cliente se a mensagem contiver o endereço dele; tudo funciona via mensagens.

A gente resolve isso enviando o pid do cliente como o primeiro termo nas mensagens:

```
defmodule Fridge do
  def start_link() do
    spawn_link __MODULE__, :loop, [[]]
  end

  def put(pid, food) do
    send pid, {self(), :put, food}
  end

  def take(pid) do
    send pid, {self(), :take}
  end

  def loop(foods) do
    receive do
      {sender, :put, food} ->
        send sender, "You put #{food} in your fridge."
        loop([food|foods])
      {sender, :take} ->
        case foods do
          [h|t] -> 
            send sender, "Take your #{h}."
            loop(t)
          [] ->
            send sender, "Nothing to eat!"
            loop([])
        end
    end
  end
end
```

Se rodarmos os mesmos comandos de novo, não vamos ver nada no REPL. Nós não usamos `IO.puts/1`, nós respondemos as mensagens para o pid de quem mandou a mensagem como sender (que no caso é o pid do REPL).

Se rodarmos `flush`, vamos ver as seguintes mensagens:

```
iex> flush
"Nothing to eat!"
"You put Apple in your fridge."
"You put Banana in your fridge."
"Take your Banana."
"Take your Apple."
"Nothing to eat!"
```

Definir ```flush``` é simples:

```
defmodule Flush do
  def my_flush() do
    receive do
      message ->
        IO.inspect(message)
        flush()
      after 10 ->
        nil
      end
  end
end
```

É um exemplo interessante: nós aceitamos qualquer mensagem no pattern match, imprimimos e chamamos flush de novo. Se demorar mais de 10 millissegundos para receber alguma mensagem, vamos assumir que a caixa de mensagens do processo está vazia e já imprimimos todas as mensagens.

Vamos colocar o flush no código do cliente, com um timeout se a geladeira por acaso não estiver ligada:

```
defmodule Fridge do
  def start_link() do
    spawn_link __MODULE__, :loop, [[]]
  end

  def put(pid, food) do
    send pid, {self(), :put, food}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end
  end

  def take(pid) do
    send pid, {self(), :take}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end    
  end

  def loop(foods) do
    receive do
      {sender, :put, food} ->
        send sender, "You put #{food} in your fridge."
        loop([food|foods])
      {sender, :take} ->
        case foods do
          [h|t] -> 
            send sender, "Take your #{h}."
            loop(t)
          [] ->
            send sender, "Nothing to eat!"
            loop([])
        end
    end
  end
end
```

Para não precisarmos ficar passando o pid da geladeira, podemos registrar o processo com um nome. O nome é único, então precisamos testar se a geladeira já não está ligada. Vamos também colocar um comando para desligar a geladeira.

```
defmodule Fridge do
  def start_link() do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :loop, [[]]
        Process.register pid, __MODULE__
      pid when is_pid(pid) ->
        IO.puts "Fridge is already running; shut it down with Fridge.shutdown first."
    end
  end

  def put(food) do
    send __MODULE__, {self(), :put, food}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end
  end

  def take() do
    send __MODULE__, {self(), :take}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end    
  end

  def shutdown() do
    send __MODULE__, {self(), :shutdown}
    receive do
      :ok -> 
        IO.inspect "Fridge shutdown."
    after 100 ->
      IO.inspect "Maybe the fridge wasn't running!"
    end
  end

  def loop(foods) do
    receive do
      {sender, :put, food} ->
        send sender, "You put #{food} in your fridge."
        loop([food|foods])
      {sender, :take} ->
        case foods do
          [h|t] -> 
            send sender, "Take your #{h}."
            loop(t)
          [] ->
            send sender, "Nothing to eat!"
            loop([])
        end
      {sender, :shutdown} ->
        send sender, :ok
    end
  end
end
```

Interessante: para desligar a geladeira nós apenas deixamos de chamar o `loop` e o processo termina. Nós enviamos uma mensagem ao cliente confirmando que a geladeira foi desligada, e dessa vez precisamos dar o match correto no átomo `:ok`. Qualquer outra resposta seria um erro.

Uma das capacidades do Erlang é trocar o código da aplicação a quente (hot code swap).

É na verdade muito simples: as aplicações sempre são baseadas em algum tipo de loop infinito, então para trocar o código da aplicação basta na hora de chamar o loop chamar uma versão mais nova. Para fazer isso, pedimos para o Erlang chamar indiretamente o loop usando `apply`.

```
defmodule Fridge do
  def start_link() do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :loop, [[]]
        Process.register pid, __MODULE__
      pid when is_pid(pid) ->
        IO.puts "Fridge is already running; shut it down with Fridge.shutdown first."
    end
  end

  def put(food) do
    send __MODULE__, {self(), :put, food}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end
  end

  def take() do
    send __MODULE__, {self(), :take}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end    
  end

  def shutdown() do
    send __MODULE__, {self(), :shutdown}
    receive do
      :ok -> 
        IO.inspect "Fridge shutdown."
    after 100 ->
      IO.inspect "Maybe the fridge wasn't running!"
    end
  end

  def update() do
    send __MODULE__, :noop
  end

  def loop(foods) do
    receive do
      {sender, :put, food} ->
        send sender, "You put #{food} in your fridge."
        apply __MODULE__, :loop, [[food|foods]]
      {sender, :take} ->
        case foods do
          [h|t] -> 
            send sender, "Take your #{h}."
            apply __MODULE__, :loop, [t]
          [] ->
            send sender, "Nothing to eat!"
            apply __MODULE__, :loop, [[]]
        end
      {sender, :shutdown} ->
        send sender, :ok
      :noop ->
        apply __MODULE__, :loop, [foods]    
    end
  end
end
```

Agora vai ficar mais fácil testar atualizar o código, basta colar de novo o módulo no REPL. O processo vai continuar rodando com o mesmo estado. Só temos que chamar Fridge.update após cada atualização do código, para entrar no loop novo. Vamos até colocar um comando, :menu, para mostrar para o usuário o que ele têm para comer, sem interromper o funcionamento:

```
defmodule Fridge do
  def start_link() do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :loop, [[]]
        Process.register pid, __MODULE__
      pid when is_pid(pid) ->
        IO.puts "Fridge is already running; shut it down with Fridge.shutdown first."
    end
  end

  def put(food) do
    send __MODULE__, {self(), :put, food}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end
  end

  def take() do
    send __MODULE__, {self(), :take}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end    
  end

  def menu() do
    send __MODULE__, {self(), :menu}
    receive do
      message -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end    
  end

  def shutdown() do
    send __MODULE__, {self(), :shutdown}
    receive do
      :ok -> 
        IO.inspect "Fridge shutdown."
    after 100 ->
      IO.inspect "Maybe the fridge wasn't running!"
    end
  end

  def update() do
    send __MODULE__, :noop
  end

  def loop(foods) do
    receive do
      {sender, :put, food} ->
        send sender, "You put #{food} in your fridge."
        apply __MODULE__, :loop, [[food|foods]]
      {sender, :take} ->
        case foods do
          [h|t] -> 
            send sender, "Take your #{h}."
            apply __MODULE__, :loop, [t]
          [] ->
            send sender, "Nothing to eat!"
            apply __MODULE__, :loop, [[]]
        end
      {sender, :menu} ->
        send sender, foods
          apply __MODULE__, :loop, [foods]
      {sender, :shutdown} ->
        send sender, :ok
    end
  end
end
```

O próximo passo é mais sutil. O cliente faz pattern-match com qualquer resposta, do servidor, mas seria interessante que esperasse pela resposta específica do seu request. O Erlang tem uma função, `make_ref/0`, que cria uma referência única na VM, e se colocarmos uma ref na mensagem podemos usar ela também na resposta do servidor e fazer pattern-match de forma específica:

```
defmodule Fridge do
  def start_link() do
    case Process.whereis(__MODULE__) do
      nil ->
        pid = spawn_link __MODULE__, :loop, [[]]
        Process.register pid, __MODULE__
      pid when is_pid(pid) ->
        IO.puts "Fridge is already running; shut it down with Fridge.shutdown first."
    end
  end

  def put(food) do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :put, food}
    receive do
      {^ref, message} -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end
  end

  def take() do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :take}
    receive do
      {^ref, message} -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end    
  end

  def menu() do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :menu}
    receive do
      {^ref, message} -> IO.inspect(message)
    after 100 ->
      IO.inspect "Is the fridge running?"
    end    
  end

  def shutdown() do
    ref = make_ref()
    send __MODULE__, {{self(), ref}, :shutdown}
    receive do
      {^ref, :ok} -> 
        IO.inspect "Fridge shutdown."
    after 100 ->
      IO.inspect "Maybe the fridge wasn't running!"
    end
  end

  def update() do
    send __MODULE__, :noop
  end

  def loop(foods) do
    receive do
      {{sender, ref}, :put, food} ->
        send sender, {ref, "You put #{food} in your fridge."}
        apply __MODULE__, :loop, [[food|foods]]
      {{sender, ref}, :take} ->
        case foods do
          [h|t] -> 
            send sender, {ref, "Take your #{h}."}
            apply __MODULE__, :loop, [t]
          [] ->
            send sender, {ref, "Nothing to eat!"}
            apply __MODULE__, :loop, [[]]
        end
      {{sender, ref}, :menu} ->
        send sender, {ref, foods}
          apply __MODULE__, :loop, [foods]
      {{sender, ref}, :shutdown} ->
        send sender, {ref, :ok}
    end
  end
end
```