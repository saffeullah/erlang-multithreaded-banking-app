-module(money).
-export([start/1]).
-import(bank, [create_bank_processes/2]).
-import(customer,[create_customer_processes/3]).


create_processes(BankInfo, CustomerInfo, Pid) ->
  BankProcesses = create_bank_processes(BankInfo, Pid),
  timer:sleep(200),
  create_customer_processes(CustomerInfo, BankProcesses,Pid).


listen_customers(BankInfo , CustomerInfo) ->
  receive
    {bankstatus, Message} ->
      io:format("1 pattern ~s~n", [Message]),
      listen_customers(BankInfo, CustomerInfo);
    {bankstatus2, Message, ReportBank} ->
      io:format("two pattern ~s~n", [Message]),
      {BankName, Balance} = ReportBank,
      UpdatedBankInfo = add_property_if_match(BankInfo, BankName, Balance),
      listen_customers(UpdatedBankInfo, CustomerInfo);
    {bankstatus3, Message, ReportBank, ReportCustomer} ->
      io:format("~s~n", [Message]),
      io:format("3 pattern~p~n", [ReportBank]),
      io:format("3 pattern~p~n", [ReportCustomer]),
     {BankName, Balance} = ReportBank,
     UpdatedBankInfo = add_property_if_match(BankInfo, BankName, Balance),
      listen_customers(UpdatedBankInfo, CustomerInfo)
%%      _ ->
%%        io:format("nothing~s~n", ["nothing"]),
% Ignore any other messages that don't match the specified patterns
%%  listen_customers(BankInfo, CustomerInfo)

  after 2000 ->
   io:format("Finished~n"),
   io:format("BankInfo: ~p~n", [BankInfo])
%  print_summary(BankInfo)
  end.




add_property_if_match(List, BankName, Balance) ->
  lists:map(fun(Tuple) ->
    case Tuple of
      {MatchName, OriginalBalance} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
      {MatchName, OriginalBalance, _} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
      _ -> Tuple
    end
            end, List).


print_summary(BankInfo) ->
  String = "Banks: ",
  io:format("~s~n", [String]),
  lists:foreach(
    fun({BankName, TotalResources, RemainingAmount}) ->
      io:format("Bank: ~p: original: ~p, balance: ~p~n", [BankName, TotalResources, RemainingAmount])
    end,
    BankInfo
  ).


start(Args) ->
  CustomerFile = lists:nth(1, Args),
  BankFile = lists:nth(2, Args),
  {ok, CustomerInfo} = file:consult(CustomerFile),
  {ok, BankInfo} = file:consult(BankFile),
  Pid = self(),
  create_processes(BankInfo, CustomerInfo, Pid),
  listen_customers(BankInfo,CustomerInfo),
  io:format("start Finished~n")
.











