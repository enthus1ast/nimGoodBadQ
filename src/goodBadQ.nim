## A simple queue template.
## in the queue template body, you can call
## itm.good
## or
## itm.bad
## on the item.
## if itm.good is called the item is removed from the queue
## if itm.bad is called the item is requeued on the end, but is not iterated over again in this call
import deques
export deques

type
  GoodBadQ*[T] = Deque[T]

proc add*[T](dq: var GoodBadQ[T], itm: T) =
  dq.addLast(itm)


proc newGoodBadQ*[T](): GoodBadQ[T] =
  result = GoodBadQ[T]

template withq*[T](dq: var Deque[T], body: untyped) =
  var goods: seq[T]
  var bads: seq[T]
  var choiceThisRound = false
  template good(itm: T) =
    choiceThisRound = true
    goods.add itm
  template bad(itm: T) =
    choiceThisRound = true
    bads.add itm
  let curlen = dq.len
  for idx in 0 ..< curlen:
    choiceThisRound = false
    let itm {.inject.} = dq[idx]
    body
    # try:
    #   body
    # except:
    #   itm.bad
    if not choiceThisRound:
      itm.bad
  dq = toDeque[T](bads)

when isMainModule:
  var ss = @["a", "b", "c"]
  var dd = ss.toDeque()


  withq dd:
    try:
      echo itm
      if itm == "a":
        itm.good
      if itm == "b":
        raise
        # raise
        # itm.bad
      # c is picked up as bad automatically
      # else:
      #   # bads.add itm
      #   itm.bad
    except:
      echo getCurrentExceptionMsg()
      itm.bad

  echo dd

