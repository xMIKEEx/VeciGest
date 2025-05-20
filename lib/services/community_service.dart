import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityService {
  Future<String?> solicitarNuevaClave(String communityId) async {
    // Lógica para generar y actualizar una nueva clave
    final nuevaClave = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .update({'clave': nuevaClave});
    return nuevaClave;
  }
}
