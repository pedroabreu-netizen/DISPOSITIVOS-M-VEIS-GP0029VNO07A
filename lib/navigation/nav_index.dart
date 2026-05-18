import 'package:flutter/material.dart';

import '../page_agenda.dart';
import '../page_home.dart';
import '../page_notas.dart';
import '../page_upload_arquivos.dart';

void navigateByIndex(BuildContext context, int currentIndex, int targetIndex) {
  if (currentIndex == targetIndex) return;

  Widget page;
  switch (targetIndex) {
    // case 0:
    //   page = const PageHome();
    //   break;
    case 1:
      page = const PageAgenda();
      break;
    // case 2:
    //   page = const PageNotas();
    //   break;
    // case 3:
    //   page = const PageUploadArquivos();
    //   break;
    default:
      page = const PageAgenda();
  }

  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
}