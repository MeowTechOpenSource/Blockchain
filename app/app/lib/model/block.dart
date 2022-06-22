class Block {
  late String from;
  late String to;
  late double amount;
  late int nonce;
  late double timestamp;
  late String hash;
  late String prevHash;
  late String title;
  late int id;

  Block({
    this.from = '',
    this.to = '',
    this.amount = 0,
    this.nonce = 0,
    this.timestamp = 0,
    this.hash = '',
    this.prevHash = '',
    this.title = 'Transaction',
    this.id = 0,
  });
}
