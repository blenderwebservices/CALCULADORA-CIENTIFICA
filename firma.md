1. Propiedades de firma en build.gradle.kts
En tu archivo 

android/app/build.gradle.kts
, la configuración de firma para la variante release está definida de la siguiente manera:

kotlin
// 1. Carga del archivo de propiedades externo (en la raíz de /android)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
// 2. Definición del bloque de firma (signingConfigs)
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties.getProperty("keyAlias")
        keyPassword = keystoreProperties.getProperty("keyPassword")
        val storeFileString = keystoreProperties.getProperty("storeFile")
        if (storeFileString != null) {
            storeFile = file(storeFileString)
        }
        storePassword = keystoreProperties.getProperty("storePassword")
    }
}
Las 4 propiedades que componen la firma son:

Propiedad	Propósito	Valor actual configurado
storeFile	Ruta relativa o absoluta al archivo del almacén de claves (Keystore).	upload-keystore.jks (resuelto en android/app/)
storePassword	Contraseña maestra para abrir el almacén .jks.	Configurada en 

android/key.properties
keyAlias	Nombre del identificador o alias de la clave privada dentro del almacén.	upload
keyPassword	Contraseña de protección específica para esa clave privada.	Configurada en 

android/key.properties
2. ¿Requieres generar firmas en esta computadora?
NO, no requieres generar ninguna firma.

He inspeccionado tu sistema y comprobado tus archivos:

El archivo de configuración existe: 

android/key.properties
 está presente y contiene las credenciales correctas.
El almacén de claves existe y está intacto: 

android/app/upload-keystore.jks
 sobrevivió a las reinstalaciones de macOS (archivo de 2.6 KB creado el 22 de septiembre de 2026).
Firma validada con keytool: Se ejecutó una verificación interna contra Java 17 y la clave respondió exitosamente:
Alias: upload
Propietario/Emisor: CN=Franc, OU=Mobile, O=BlenderWebServices, C=MX
Vigencia: Válido hasta el 7 de febrero de 2054.
Huella SHA-256: 2C:62:69:61:F1:53:F1:42:21:BC:B6:CF:7D:A5:C9:EE:88:48:93:14:8A:CA:2B:2D:42:90:FB:F9:C5:B3:5C:EA
WARNING

No generes una clave nueva si la app ya fue publicada en Google Play:
Si generas un nuevo keystore con una huella SHA-256 distinta, Google Play Console rechazará cualquier nueva actualización del APK o Android App Bundle (.aab), impidiendo publicar versiones nuevas a menos que solicites un proceso de restablecimiento ante el soporte de Google.

3. Recomendación crítica: Realiza un respaldo externo ahora
Ambos archivos (

android/key.properties
 y 

android/app/upload-keystore.jks
) están correctamente protegidos en tu archivo .gitignore para no ser publicados en GitHub.

Dado que has tenido dos reinstalaciones de macOS recientemente, te recomiendo encarecidamente guardar una copia de seguridad externa de estos dos archivos (en una memoria USB cifrada, gestor de contraseñas como Bitwarden/1Password o almacenamiento seguro en la nube) para evitar perderlos en el futuro.