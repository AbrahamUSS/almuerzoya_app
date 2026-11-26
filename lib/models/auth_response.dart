class AuthResponse {
  final String token;
  final String tipo;
  final DateTime? expiraEn;
  final String nombre;
  final String email;
  final String rol;

  const AuthResponse({
    required this.token,
    required this.tipo,
    required this.expiraEn,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final expira = json['expiraEn'];
    return AuthResponse(
      token: json['token'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'Bearer',
      expiraEn: expira == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch((expira as num).toInt()),
      nombre: json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      rol: json['rol'] as String? ?? 'USER',
    );
  }
}
