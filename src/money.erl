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
      io:format("~s~n", [Message]),
      listen_customers(BankInfo, CustomerInfo);
    {bankstatus2, Message, ReportBank} ->
      io:format("~s~n", [Message]),
      {BankName, Balance} = ReportBank,
      UpdatedBankInfo = add_property_if_match(BankInfo, BankName, Balance),
      listen_customers(UpdatedBankInfo, CustomerInfo);
    {bankstatus3, Message, ReportBank, ReportCustomer} ->
      io:format("~s~n", [Message]),
%%      io:format("3 pattern~p~n", [ReportBank]),
%%      io:format("3 pattern~p~n", [ReportCustomer]),
     {BankName, Balance} = ReportBank,
     {CustomerName, LoanRequest} = ReportCustomer,
     UpdatedBankInfo = add_property_if_match(BankInfo, BankName, Balance),
     UpdatedCustomerInfo = track_customer_obtained_loan(CustomerInfo, CustomerName, LoanRequest),
      listen_customers(UpdatedBankInfo, UpdatedCustomerInfo)

  after 2000 ->
  print_summary(BankInfo, CustomerInfo)
  end.

track_customer_obtained_loan(List, CustomerName, LoanAmount) ->
  lists:map(fun(Tuple) ->
    case Tuple of
      {MatchName, OriginalLoanRequest} when MatchName == CustomerName -> {MatchName, OriginalLoanRequest, LoanAmount};
      {MatchName, OriginalLoanRequest, OriginalLoan} when MatchName == CustomerName -> {MatchName, OriginalLoanRequest, OriginalLoan + LoanAmount};
      _ -> Tuple
    end
            end, List).


add_property_if_match(List, BankName, Balance) ->
  lists:map(fun(Tuple) ->
    case Tuple of
      {MatchName, OriginalBalance} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
      {MatchName, OriginalBalance, _} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
      _ -> Tuple
    end
            end, List).

print_summary(BankInfo, CustomerInfo) ->
io:format("~n~s~n~n", ["**Banking Report **"]),
  io:format("~s~n", ["Customers: "]),
  lists:foreach(
    fun({CustomerName, OriginalLoanRequest, LoanGiven}) ->
      io:format("~p: , objective  ~p , received ~p~n", [CustomerName, OriginalLoanRequest, LoanGiven])
    end,
    CustomerInfo
  ),
  print_total_customer_loan(CustomerInfo),
  io:format("~n~s~n", ["Banks: "]),
  lists:foreach(
    fun({BankName, TotalResources, RemainingAmount}) ->
      io:format("~p:, original ~p, balance ~p~n", [BankName, TotalResources, RemainingAmount])
    end,
    BankInfo),
  print_total_loan_dispersed(BankInfo).

print_total_customer_loan(CustomerInfo) ->
  {TotalObjective, TotalBalance} = lists:foldl(fun({_, Objective, Balance}, {AccObjective, AccBalance}) ->
    {AccObjective + Objective, AccBalance + Balance}
                                               end, {0, 0}, CustomerInfo),
  io:format("~s~n", ["-----"]),
  io:format("Total: objective ~p, received ~p~n", [TotalObjective, TotalBalance]).

print_total_loan_dispersed(BankInfo) ->
  {TotalObjective, TotalBalance} = lists:foldl(fun({_, Objective, Balance}, {AccObjective, AccBalance}) ->
  {AccObjective + Objective, AccBalance + Balance}
  end, {0, 0}, BankInfo),
  io:format("~s~n", ["-----"]),
  io:format("Total: original ~p, loaned ~p~n", [TotalObjective, TotalObjective - TotalBalance]).

start(Args) ->
  CustomerFile = lists:nth(1, Args),
  BankFile = lists:nth(2, Args),
  {ok, CustomerInfo} = file:consult(CustomerFile),
  {ok, BankInfo} = file:consult(BankFile),
  Pid = self(),
  String1 = "** The financial market is opening for the day **",
  String2 =  "Starting transaction log...",
  io:format("~n~s~n~n~s~n", [String1, String2] ),
  create_processes(BankInfo, CustomerInfo, Pid),
  listen_customers(BankInfo,CustomerInfo).
