-module(bank).
-export([create_bank_processes/2]).

create_bank_processes(BankInfo, Pid) ->
  lists:map(
    fun({BankName, BankResources}) ->
      {BankName, spawn_link(fun() -> bank_process({BankName, BankResources}, Pid) end)}

    end,
    BankInfo
  )
  .


bank_process(BankTuple, Pid) ->
  {BankName, BankResources} = BankTuple,
  receive
    {From, {CustomerName, RandomLoan}} ->
      case BankResources >= RandomLoan of
        true->
          UpdatedBankResources = BankResources- RandomLoan,
          BankMessage = "$ The " ++ atom_to_list(BankName) ++ " bank approves a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) to " ++ atom_to_list(CustomerName),
          ReportBankData = {BankName, UpdatedBankResources},
          ReportCustomerData = {CustomerName, RandomLoan},
         Pid ! { bankstatus3, BankMessage, ReportBankData, ReportCustomerData},
          From ! {self(), {BankName, accepted}},
          bank_process({BankName, UpdatedBankResources}, Pid);
        false ->
          BankMessage = "$ The " ++ atom_to_list(BankName) ++ " bank denies a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) to " ++ atom_to_list(CustomerName),
          Pid ! {bankstatus2, BankMessage, BankTuple},
          From ! {self(), {BankName, rejected}},
          bank_process(BankTuple, Pid) % Continue listening for requests
      end
  end
  ,io:format("Bank thread exited~n")
  .