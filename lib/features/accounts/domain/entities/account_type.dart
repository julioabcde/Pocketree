enum AccountType {
  cash('cash'),
  bankAccount('bank_account'),
  eWallet('e_wallet'),
  creditCard('credit_card');

  final String value;
  const AccountType(this.value);

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown AccountType: $value'),
    );
  }

  bool get isAsset => this != creditCard;

  bool get isLiability => this == creditCard;
}
