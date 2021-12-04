class CountDown {
  final int? id;
  final int? seconds;
  final String? date;

  CountDown({
    this.id,
    required this.seconds,
    required this.date,
  });

  factory CountDown.fromMap(Map<String, dynamic> json) => new CountDown(
      id: json['id'], seconds: json['seconds'], date: json['date']);

  Map<String, dynamic> toMap() {
    return {'id': id, 'seconds': seconds, 'date': date};
  }
}
