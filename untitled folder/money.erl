-module(money).
-export([start/1]).
-import(bank, [create_bank_processes/2]).
-import(customer,[create_customer_processes/3]).


create_processes(BankInfo, CustomerInfo, Pid) ->
  BankProcesses = create_bank_processes(BankInfo, Pid),
  timer:sleep(200),
  CustomerProcesses = create_customer_processes(CustomerInfo, BankProcesses,Pid)
.

listen_customers(BankInfo) ->
  receive
%%    {_, Message, ReportBank} ->
%%%%      io:format("~s~n", [Message]),
%%      {BankName, Balance} = ReportBank,
%%      UpdatedBankInfo = add_property_if_match(BankInfo, BankName, Balance),
%%
%%      listen_customers(UpdatedBankInfo);
%%    _ ->
%%      % Default message handler code here
%%      io:format("Received an unexpected message.~n"),
%%      listen_customers(BankInfo)
  after 5000 ->
    print_summary()
  end.

add_property_if_match(List, BankName, Balance) ->
  lists:map(fun(Tuple) ->
    case Tuple of
      {MatchName, OriginalBalance} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
      {MatchName, OriginalBalance, _} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
      _ -> Tuple
    end
            end, List).


print_summary() ->
  String = "Printing Summary",
  io:format("~s~n", [String]).


start(Args) ->
  CustomerFile = lists:nth(1, Args),
  BankFile = lists:nth(2, Args),
  {ok, CustomerInfo} = file:consult(CustomerFile),
  {ok, BankInfo} = file:consult(BankFile),
  Pid = self(),
  create_processes(BankInfo, CustomerInfo, Pid),
  listen_customers(BankInfo).











