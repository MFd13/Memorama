class Data {
  int? id;
  String? fecha;
  int? wins;
  int? loses;
  Data({
    this.id,
    this.fecha,
    this.wins,
    this.loses
  });

  Map<String, dynamic> toMap() {
    return {'id':id,'fecha': fecha, 'victorias': wins, 'derrotas': loses};
  }
}
