-module(pushsum).

-export([push_sum_worker/4]).

get_random_neighbor(Neighbors) ->
  lists:nth(rand:uniform(length(Neighbors)),Neighbors).

push_sum_worker(N, ExistingS, ExistingW, Neighbors) ->
  UpperLimit = 0.0000000001,
  receive
    hello ->
      io:format("Inside the pushsum~n");
    {setup, NeighborList} ->
      io:format("Neighbors of ~p are: ~p~n", [self(), NeighborList]),
      tpid ! iamready,
      push_sum_worker(N, ExistingS, ExistingW, NeighborList);
    {rumor, S, W} ->
      UpperC = ExistingS + S,
      UpdatedC = ExistingW + W,
      CHalf = UpperC/2,
      UpdatedCHalf = UpdatedC/2,
      AbsDiff = abs(UpperC/UpdatedC - ExistingS/ExistingW),
      if
        (AbsDiff < UpperLimit) and (N >= 3) ->
          tpid ! {heard, UpperC/UpdatedC};
        (AbsDiff < UpperLimit) and (N < 3) ->
          get_random_neighbor(Neighbors) ! {rumor, CHalf, UpdatedCHalf},
          push_sum_worker(N+1, CHalf, UpdatedCHalf, Neighbors);
        AbsDiff >= UpperLimit->
          get_random_neighbor(Neighbors) ! {rumor, CHalf, UpdatedCHalf},
          push_sum_worker(0, CHalf, UpdatedCHalf, Neighbors)
      end
  end,
  push_sum_worker(N, ExistingS, ExistingW, Neighbors).

