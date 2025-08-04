import 'package:flutter/material.dart';
import 'package:aluxe/backend/aluxe_database.dart';

class RetosMateriaScreen extends StatefulWidget {
  final String token;
  final String materia;
  final String materiaNombre;

  const RetosMateriaScreen({
    super.key,
    required this.token,
    required this.materia,
    required this.materiaNombre,
  });

  @override
  State<RetosMateriaScreen> createState() => _RetosMateriaScreenState();
}

class _RetosMateriaScreenState extends State<RetosMateriaScreen> {
  final AluxeDatabase _db = AluxeDatabase.instance();
  List<Map<String, dynamic>> _retos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarRetos();
  }

  Future<void> _cargarRetos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final retos = await _db.getRetosByMateria(
        token: widget.token,
        materia: widget.materia,
      );

      setState(() {
        _retos = retos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar retos: $e';
        _isLoading = false;
      });
    }
  }

  Color _getMateriaColor() {
    switch (widget.materia) {
      case 'matematicas':
        return Colors.red;
      case 'comunicacion':
        return Colors.green;
      case 'personal_social':
        return Colors.orange;
      case 'ciencia_tecnologia':
        return Colors.purple;
      case 'ingles':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getMateriaIcon() {
    switch (widget.materia) {
      case 'matematicas':
        return Icons.calculate;
      case 'comunicacion':
        return Icons.book;
      case 'personal_social':
        return Icons.people;
      case 'ciencia_tecnologia':
        return Icons.science;
      case 'ingles':
        return Icons.language;
      default:
        return Icons.subject;
    }
  }

  String _getNivelTexto(String nivel) {
    switch (nivel) {
      case 'facil':
        return 'Fácil';
      case 'medio':
        return 'Medio';
      case 'dificil':
        return 'Difícil';
      default:
        return nivel;
    }
  }

  Color _getNivelColor(String nivel) {
    switch (nivel) {
      case 'facil':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'dificil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getMateriaColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materiaNombre),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarRetos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarRetos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_retos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getMateriaIcon(), size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay retos disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Los profesores pueden crear retos para esta materia',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarRetos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _retos.length,
        itemBuilder: (context, index) {
          final reto = _retos[index];
          return _buildRetoCard(reto);
        },
      ),
    );
  }

  Widget _buildRetoCard(Map<String, dynamic> reto) {
    final color = _getMateriaColor();
    final nivel = reto['nivel'] ?? 'medio';
    final puntos = reto['puntos'] ?? 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _iniciarReto(reto),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMateriaIcon(),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reto['titulo'] ?? 'Sin título',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getNivelColor(nivel),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getNivelTexto(nivel),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$puntos pts',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reto['descripcion'] ?? 'Sin descripción',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _iniciarReto(Map<String, dynamic> reto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResolverRetoScreen(token: widget.token, reto: reto),
      ),
    ).then((resultado) {
      if (resultado == true) {
        // El reto fue completado, refrescar la lista
        _cargarRetos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reto completado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}

class ResolverRetoScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> reto;

  const ResolverRetoScreen({
    super.key,
    required this.token,
    required this.reto,
  });

  @override
  State<ResolverRetoScreen> createState() => _ResolverRetoScreenState();
}

class _ResolverRetoScreenState extends State<ResolverRetoScreen> {
  final AluxeDatabase _db = AluxeDatabase.instance();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final puntos = widget.reto['puntos'] ?? 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolver Reto'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            // Información del reto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reto['titulo'] ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.reto['descripcion'] ?? 'Sin descripción',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$puntos puntos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón para completar (simulación)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Has completado este reto?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Marca como completado para ganar los puntos',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _completarReto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Completar Reto (+$puntos pts)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completarReto() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await _db.completarReto(
        token: widget.token,
        retoId: widget.reto['id'],
        puntosObtenidos: widget.reto['puntos'] ?? 10,
      );

      if (success && mounted) {
        Navigator.pop(context, true); // Retornar éxito
      } else {
        setState(() {
          _error = 'Error al completar el reto';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
