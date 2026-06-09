import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class VinculoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Duration validadeCodigo = Duration(minutes: 10);

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _db.collection('usuarios');

  Future<String> gerarCodigo(String idosoUid) async {
    final codigo = (Random().nextInt(900000) + 100000).toString();
    final expiraEm = Timestamp.fromDate(DateTime.now().add(validadeCodigo));

    await _usuarios.doc(idosoUid).update({
      'codigoVinculo': codigo,
      'codigoVinculoExpiraEm': expiraEm,
    });

    return codigo;
  }

  Future<void> vincularComCodigo({
    required String cuidadorUid,
    required String codigo,
  }) async {
    final resultado = await _usuarios
        .where('codigoVinculo', isEqualTo: codigo)
        .limit(1)
        .get();

    if (resultado.docs.isEmpty) {
      throw Exception('Código inválido. Confira com o idoso e tente novamente.');
    }

    final idosoDoc = resultado.docs.first;
    final expiraEm = idosoDoc.data()['codigoVinculoExpiraEm'] as Timestamp?;

    if (expiraEm == null || expiraEm.toDate().isBefore(DateTime.now())) {
      throw Exception('Código expirado. Peça ao idoso para gerar um novo.');
    }

    final batch = _db.batch();

    batch.update(idosoDoc.reference, {
      'cuidadorUid': cuidadorUid,
      'codigoVinculo': FieldValue.delete(),
      'codigoVinculoExpiraEm': FieldValue.delete(),
    });

    batch.update(_usuarios.doc(cuidadorUid), {
      'idosoUid': idosoDoc.id,
    });

    await batch.commit();
  }

  Future<Map<String, dynamic>?> buscarUsuarioVinculado(
    String uid,
    String tipoUsuario,
  ) async {
    final doc = await _usuarios.doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    final campoVinculo = tipoUsuario == 'idoso' ? 'cuidadorUid' : 'idosoUid';
    final outroUid = doc.data()?[campoVinculo] as String?;

    if (outroUid == null) {
      return null;
    }

    final outroDoc = await _usuarios.doc(outroUid).get();

    return outroDoc.exists ? outroDoc.data() : null;
  }
}
