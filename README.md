# Curso de Elixir

Na pasta `snippets` vamos colocando exercícios sobre a linguagem.

Para rodar os snippets:

`iex -r <nome do snippet>`

## Talks

Vamos colocar aqui uma lista de talks sobre Elixir, Phoenix e OTP.

Tem alguns especialmente bons do Valim sobre Elixir, Ecto e Phoenix.

## Overview

### Elixir (Erlang) é uma linguagem com duas partes: a sequencial e a concorrente.

A linguagem sequencial é usada para escrever código organizado em funções e módulos.

A linguagem concorrente é usada para criar processos que executam o código sequencial e que se comunicam via mensagens.

#### A linguagem sequencial

A linguagem sequencial é funcional com tipos dinâmicos.

As principais estruturas de dado são as tuplas (listas de tamanho fixo, geralmente 2-4 elementos), as lista ligadas (cada lista é uma cabeça com uma cauda) e os mapas (tabelas com chave e valor).

Os valores são manipulados usando pattern-matching e funções que retornam uma cópia nova do valor. As variáveis nunca são alteradas, são copiadas e transformadas.

O controle de fluxo é feito com IFs mas não há loops, é preciso usar recursão. Mas a recursão é muito fácil com pattern-matching.

Não existem classes e objetos, apenas funções e módulos que agrupam essas funções para efeito de organização e compilação.

Como não há mutação de valores, quando dois processos são chamados com o mesmo valor inicial, não precisamos nos preocupar com sincronização entre os processos. Cada processo tem uma cópia do valor original e quaisquer alterações criarão uma nova cópia separada.

Material de estudo para pegar o básico de como escrever código bem simples:

Para começar (são páginas pequenas):

- https://elixir-lang.org/getting-started/introduction.html
- https://elixir-lang.org/getting-started/basic-types.html
- https://elixir-lang.org/getting-started/basic-operators.html
- https://elixir-lang.org/getting-started/pattern-matching.html
- https://elixir-lang.org/getting-started/case-cond-and-if.html
- https://elixir-lang.org/getting-started/keywords-and-maps.html
- https://elixir-lang.org/getting-started/modules-and-functions.html
- https://elixir-lang.org/getting-started/try-catch-and-rescue.html
- https://elixirschool.com/en/lessons/basics/basics/
- https://elixirschool.com/en/lessons/basics/collections/
- https://elixirschool.com/en/lessons/basics/pattern-matching/
- https://elixirschool.com/en/lessons/basics/control-structures/
- https://elixirschool.com/en/lessons/basics/pipe-operator/
- https://elixirschool.com/en/lessons/basics/modules/
- https://elixirschool.com/en/lessons/advanced/error-handling/

Se der tempo...

- https://elixir-lang.org/getting-started/enumerables-and-streams.html
- https://elixir-lang.org/getting-started/recursion.html
- https://elixir-lang.org/getting-started/module-attributes.html
- https://elixir-lang.org/getting-started/structs.html

#### A linguagem concorrente

Todo código roda em um processo, que é como um processo de sistema operacional, mas gerenciado pela máquina virtual do Elixir, e cada processo requer menos de 1kb de memória para ser criado e leva poucos microssegundos para rodar (processos de sistema operacional são muito mais pesados e lentos).

Como os processos são muito leves, um sistema pode facilmente rodar com dezenas de milhares de processos.

Os processos não tem estado no sentido comum. Quando iniciamos um processo nós rodamos uma função com alguns argumentos. O processo termina quando a função termina, e se quisermos um processo longo, nós fazemos uma recursão no final da própria função chamando ela de novo. Então o "estado" do processo fica no argumentos que vamos passando quando damos uma recursão na função do processo.

Por exemplo, um pequeno servidor se parece com:

```elixir
def loop(state) do
  receive do
    {:set, value} -> loop(value)
    {:get, sender} -> send sender, state; loop(state)
    other -> Logger.info("Couldn't understand; #{other}"); loop(state)
  end
end
```

Outros processos não podem afetar `state`; eles podem mandar mensagens para o processo rodando `loop`, mas não há estado compartilhado.

Para iniciar um processo que rode a função `loop` com estado inicial `0` basta:

```elixir
spawn fn ->
  loop(0)
end
```

Se usarmos `spawn_link`:

```elixir
spawn_link fn ->
  loop(0)
end
```

Então se o processo do `loop` travar, o processo que chamou `spawn_link` vai receber da VM uma mensagem avisando que o filho travaou.

Nós geralmente não usamos as primitivas de `spawn` nem nos ocupamos muito com código concorrente quando escrevemos alguma serviço web. As bibliotecas de HTTP (como Plug) já cuidam da concorrência do servidor, gerenciando um pool de processos para cuidar dos requests. A parte do código que escrevemos em geral já está dentro de alguma abstração de concorrência.

Como os processos não compartilham estado e a VM notifica falhas entre processos, é possível criar árvores de processos que reiniciam os filhos quando eles travam. Como esses processos são levíssimos, Erlang/Elixir são uma ótima linguagem para escrever servidores extremamente escaláveis e de alta disponibilidade.

Por isso o comportamento comum em Erlang é deixar os processos travarem ao invés de escrever código extremamente defensivo.

### Garbage collection e concorrência/alta disponibilidade

Como cada processo tem seu próprio espaço na memória, a coleta de lixo pode ser feita individualmente. Quando um processo passa por coleta de lixo, nenhum outro processo é pausado! A BEAM (a máquina virtual do Elixir) permite portanto coleta de lixo concorrente.

Material de estudo:

- https://elixir-lang.org/getting-started/processes.html
- https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html
- https://elixir-lang.org/getting-started/mix-otp/agent.html
- https://elixir-lang.org/getting-started/mix-otp/genserver.html
- https://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html
- https://elixirschool.com/en/lessons/advanced/concurrency/
- https://elixirschool.com/en/lessons/advanced/otp-concurrency/
- https://elixirschool.com/en/lessons/advanced/otp-supervisors/
- https://elixirschool.com/en/lessons/advanced/behaviours/

### Ferramentas

O tooling para Elixir é bastante completo.

#### IEx: REPL (read-eval-print-loop) para Elixir.

- https://elixirschool.com/en/lessons/basics/iex-helpers
- https://elixir-lang.org/getting-started/debugging.html

#### Mix: Projetos/build

- https://elixirschool.com/en/lessons/basics/mix/
- https://elixirschool.com/en/lessons/basics/mix-tasks/

#### Hex: Package manager

#### ExUnit: Framework de testes unitários

- https://elixirschool.com/en/lessons/basics/testing/

#### ExDoc: Framework para gerar documentação

- https://elixirschool.com/en/lessons/basics/documentation/

### Material de estudo:

#### Bibliotecas importantes

Existem algumas bibliotecas de uso comum em Elixir para projetos web.

##### Plug

Plug é uma biblioteca para escrever servidores de HTTP. Os "plugs" são juntados num pipeline que processa um request. Por exemplo um plug faz o parsing do corpo do request, outro valida parâmetros, outro faz a lógica de negócio, outro roteia a request para módulos específicos.

No final do pipeline, um plug simplesmente retorna um objeto com a resposta que deve ser enviada ao cliente.

O plug faz apenas a lógica para cima do HTTP; o HTTP em si é gerenciado por uma biblioteca que não usamos diretamente, a Cowboy, que por sua vez roda por cima do Ranch, que gerencia recursos de rede junto ao sistema operacional.

- https://elixirschool.com/en/lessons/specifics/plug/
- https://github.com/elixir-plug/plug

##### Ecto

Ecto é o ORM do Elixir. Com o Ecto podemos escrever migrações, definir modelos sobre tabelas de bancos de dados, e realizar consultas e alterações nos bancos. Mas o Plug não trabalha com ActiveRecords como Rails. Ele trabalha com o Repository Pattern, mais comum em Java e .NET.

- https://elixirschool.com/en/lessons/specifics/ecto/

##### Phoenix

Phoenix é um framework completo para programar web em Elixir. Ele roda usando Plugs, mas traz o tipo de conveniência do Rails: controllers, autenticação, cache, session management, views, live code reloading, etc. Sobre usar Plug ou Phoenix depende muito do tipo de aplicação. O Plug é suficiente para muita coisa.

## Um projeto para aprender

O projeto é criar um servidor de to-do com uma interface HTTP usando Plug, persistência em SQL usando Ecto, e rodando sob uma árvore de supervisão. Os to-dos devem ser distribuídos entre N servidores. Na prática o SQL será um gargalo, mas o exercício serve do mesmo jeito.

## FAQ

### O que é OTP?

OTP é Open Telecom Platform. É um conjunto de biliotecas (módulos) e abstrações para escrever aplicações distribuídas. Por exemplo, o GenServer é uma abstração de um servidor com um loop principal que pode receber mensagens assíncronas (_casts_), receber e responder mensagens síncronas (_calls_), ser adicionado a uma árvore de supervisão. O GenServer inclui também um lógica para lidar com timeouts.

### Por quê usamos listas e não arrays? Qual a diferença?

Listas são compostas de um primeiro elemento (head) e outra lista (tail):

```elixir
[1, 2, 3] == [1|[2|[3]]]
```

Em em termos de estruturas de dados (& é um ponteiro, informalmente):

```elixir
X1 = (1, &X2)
X2 = (2, &X3)
X3 = (3, NULL)
```

Arrays tem tamanho fixo e (tipicamente) correspondem a uma região contígua de memória.

O acesso em arrays é mais rápido, basta usar um offset para calcular onde na memória está um elemento.

Em listas precisamos sempre percorrer os ponteiros.

O benefício de listas é que podem mudar de tamanho, representam muito facilmente listas e filas, e suportam pattern-matching. O compilador não consegue fazer pattern-matching em arrays sem saber o tamanho delas de antemão. Além disso, trabalhar recursivamente com listas é muito fácil:

```elixir
def sum([]), do: 0
def sum([x|xs]) do
  x + sum(xs)
end
```

Arrays são mais adequadas para computação numérica, mas em Elixir/Erlang sempre estamos mais interessado em performance em redes e I/O em geral. Como é fácil ler o primeiro elemento de listas, não perdemos performance por usá-las.
