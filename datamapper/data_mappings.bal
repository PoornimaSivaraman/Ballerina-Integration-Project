function transformed(Input input) returns Output => {
    accountInfo: {accountNumber: input.account.accountNumber, balance: input.account.balance},
    fullName: input.user.firstName + input.user.lastName,
    location: {city: input.user.address.city, state: input.user.address.state, zipCode: ""},
    transactionDate: "",
    contactDetails: {email: input.user.email, primaryPhone: input.user.phoneNumbers[0]}
};
