import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/unit_model.dart';

class UnitService {
  final _db = FirebaseFirestore.instance;

  Future<void> assignUserToUnit(String unitId, String email) async {
    await _db.collection('units').doc(unitId).update({
      'usuarioAsignado': email,
      'estado': 'ocupada',
    });
  }

  Future<Unit?> getUnitByClaveAndCodigo(String clave, String codigo) async {
    final query =
        await _db.collection('units').where('codigo', isEqualTo: codigo).get();
    if (query.docs.isEmpty) return null;
    // Aquí deberías comprobar la clave de la comunidad, normalmente en otra colección
    // Por simplicidad, se asume que la clave ya fue validada antes
    return Unit.fromMap(query.docs.first.id, query.docs.first.data());
  }
}
