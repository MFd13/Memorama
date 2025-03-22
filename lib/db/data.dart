class Data {
  int? id;
  String? fecha;
  String? hora;
  int? wins;
  int? loses;
  Data({
    this.id,
    this.fecha,
    this.hora,
    this.wins,
    this.loses
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'hora': hora,
      'victorias': wins,
      'derrotas': loses
    };
  }
}