# Tío Mariscal — V1

Prototipo funcional Flutter de fidelización para CTMS.

## Regla principal
- Cada factura aprobada suma 1 viaje.
- 10 viajes aprobados = 1 pasaje gratis.
- Al entregar el premio se inicia un nuevo ciclo 0/10.
- El historial anterior se conserva.

## Incluye
- Inicio con progreso 0/10.
- Registro de viaje/factura (modo demo local).
- Historial de facturas con estados.
- Pantalla de premios.
- Perfil del pasajero.
- Panel administrador demo para aprobar/rechazar facturas y entregar premios.
- Imágenes originales suministradas por CTMS usadas como assets, sin regenerarlas.

## Ejecutar
1. Instalar Flutter estable.
2. En esta carpeta ejecutar `flutter create .` para generar carpetas nativas Android/iOS si no existen.
3. Ejecutar `flutter pub get`.
4. Ejecutar `flutter run`.

## Próxima fase
Sustituir el estado local por Firebase Auth + Firestore + Storage + Cloud Messaging, con transacciones de servidor para impedir facturas duplicadas y premios dobles.

## Generar APK con GitHub Actions
Al subir este proyecto a la rama `main`, GitHub Actions ejecuta `.github/workflows/build-apk.yml` y genera un artefacto llamado **TioMariscal-APK** que contiene `app-release.apk`.
