//
//  Constant+Payment.swift
//  levelD
//
//  Created by Parvind Bhatt on 19/03/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

enum PaymentType: String {
    case bank = "Bank Account"
    case card = "Credit Card"
}

struct BankPlaceHolderKey {
    static let BSB = "BSB"
    static let AccountNumber = "Account Number"
    static let AccountHolderName = "Account Holder Name"
    static let State = "State"
    static let City = "City"
    static let Street = "Street"
}

struct BankPlaceHolderValue {
    static let BSBValue = "Enter BSB"
    static let AccountNumberValue = "E.g. 3939 93984 239943 394"
    static let AccountHolderNameValue = "E.g. James"
    static let StateValue = "E.g. Melbourne"
    static let CityValue = "E.g. Victoria"
    static let StreetValue = "E.g. St. Louis"
}

struct CardPlaceHolderKey {
    static let Name = "Name on Card"
    static let CardNumber = "Card Number"
    static let ValidThru = "Expiration Date"
    static let CVV = "CVV"
}

struct CardPlaceHolderValue {
    static let NameValue = "Enter name on card"
    static let CardNumberValue = "E.g. 3939 93984 239943 394"
    static let ValidThruValue = "E.g. 03/2019"
    static let CVVValue = "E.g. 232"
}

struct CardTextFieldsTag {
    static let nameField = 501
    static let cardNumberField = 502
    static let vaildField = 503
    static let cvvField = 504
}

struct BankTextFieldsTag {
    static let bsbField = 601
    static let accountNumberField = 602
    static let accountHolderNameField = 603
}

struct PaymentValidationMessages {
    static let emptyName   = "Name can’t be empty."
    static let nameRange = "Name can’t be less then 3"
    static let emptyCardNumber = "Card Number can’t be empty."
    static let cardRange = "Card Number can’t be less then 12."
    static let emptyCVV        = "CVV should not be left empty."
    static let cvvRange        = "CVV should not be less than 3 digit."
    static let expiry = "Expiration date cannot be selected for past date."
    static let expiryEmpty = "Expiration date should not be left empty."
    static let emptyBSB   = "BSB can’t be empty."
    static let bsbRange = "BSB can’t be less then 12"
    static let emptyAccountNumber   = "Account Number can’t be empty."
    static let accountRange = "Account Number can’t be less then 12"
    
}
