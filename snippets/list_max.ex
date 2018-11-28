defmodule Lists do
  """
  Como achar o maior elemento de uma lista?

  Em uma linguagem imperativa comum, escreveríamos algo como:

  function max(arr) {

    var largest_so_far = arr[0];

    for (var i = 0; i < arr.length; i++) {
      if (arr[i] > largest_so_far) {
        largest_so_far = arr[i]
      }
    }

    return largest_so_far;
  }

  O que é característico de linguagens imperativas aqui:

  - Acessar o elemento de uma array via um índice
  - Iterar através de uma lista usando um índice
  - O índice é uma variável mutável, fazendo do código "stateful"
  - Manter o maior número já visto em uma variável também mutável

  Em código funcional e imutável, nós temos duas abordagens básicas
  baseadas em recursão: uma com acumulador, e uma sem acumulador.

  A com acumulador é mais eficiente em termos de memória; a sem
  acumulador é mais simples.
  """

  """
  list_max usa um acumulador (um valor passado como argumento
  ao longo das recursões contendo o resultado da computação
  até o momento). No caso, o acumulador é o maior número encontrado
  até então.
  """

  """
  Usamos pattern matching para definir os vários casos da função.

  Quando chamamos list_max/1 sobre uma lista, usamos
  o primeiro elemento como o maior já visto, e aplicamos
  list_max/2 com resto da lista (tail) e o primeiro (head)
  como maior.

  O código ainda lembra a versão imperativa por manter
  um acumulador do maior elemento já visto.
  """

  def list_max([h | t]), do: list_max(t, h)

  """
  Nas chamadas seguintes, se o primeiro elemento da lista
  é maior que o acumulador (max), então fazemos a recursão
  sobre o resto da lista usando este primeiro elemento como novo max.

  Caso contrário, fazemos a recursão sobre o resto da lista
  mantendo o mesmo valor como max.
  """

  def list_max([h | t], max) when h > max, do: list_max(t, h)
  def list_max([h | t], max), do: list_max(t, max)

  """
  Quando chamamos list_max com uma lista vazia, significa que
  terminamos de analisar a lista e o resultado é max, o maior
  valor visto ao longo da recursão toda.
  """

  def list_max([], max), do: max

  """
  Uma abordagem mais idiomática funcional aparece quando
  pensamos na definição do que é um valor máximo em uma lista.

  O valor máximo de uma lista [h|t] é:
  - h se h > max(t)
  - caso contrario, max(t)

  O valor máximo de uma lista de um elemento [h] é h.

  Esta definição nos dá diretamente uma implementação recursiva
  da função.
  """

  """
  Em uma lista de um elemento o valor máximo é o próprio elemento.
  """

  def list_max2([h]) do
    h
  end

  """
  Em uma lista composta de um elemento (head) e outra lista (tail),
  o máximo elemento é o maior entre o head e o máximo do tail.

  (Podemos obviamente otimizar o código calculando list_max2 só uma vez)
  """

  def list_max2([h | t]) do
    if h > list_max2(t) do
      h
    else
      list_max2(t)
    end
  end

  """
  Em Haskell, o código seria ainda mais sucinto:

  max :: [Int] -> Int
  max [x] = x
  max (x:xs) = if x > max xs then x else max xs

  Em Ocaml também:

  let rec max list =
    match list with
    | (x :: xs) -> if x > max xs then x else max xs
    | [x] -> x

  E com a pequena otimização (Haskell):

  max :: [Int] -> Int
  max [x] = x
  max (x:xs) =
    let m = max xs in
      if x > m then
        x
      else
        m
  """
end
