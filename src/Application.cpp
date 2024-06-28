#include "Application.h"
#include "ApplicationStorageFormat.h"

#include <QRegularExpression>
#include <QCoreApplication>
#include <QLocale>
#include <QFile>

Application::Application(QString fileName, QObject *parent)
    : QObject(parent), m_fileName(fileName) {}

bool Application::parse() {
  // Supporting only .destop files (Linux OS)
  static const QSettings::Format DesktopFileFormat = QSettings::registerFormat(
      "desktopfile", desktopFileRead, desktopFileWrite);
  QString locale = QLocale::system().name().split(QRegExp("_")).at(0);

  DEBUG_MSG("Parsing " << fileName() << " file...");

  QSettings settings(fileName(), DesktopFileFormat);
  QRegExp ignoredApps = QRegExp(IGNORED_APPS_REGEXP);
  settings.setIniCodec("UTF-8");

  // Check if the Application exist if TryExec is set.
  // If the application doesnt exists also mark as invalid
  this->setTryExec(
      escapeValue(settings.value(DESKTOP_KEY_TRY_EXEC).toString()));
  if (!testFile()) {
    DEBUG_MSG("Parsing " << fileName() << " file FAILED!");
    return false;
  }

  // Parse remaining attributes
  setName(escapeValue(settings.value(DESKTOP_KEY_NAME).toString()));
  setNameLocalized(escapeValue(
      getLocalizedValue(settings, locale, DESKTOP_KEY_NAME).toString()));
  setGenericName(
      escapeValue(settings.value(DESKTOP_KEY_GENERIC_NAME).toString()));
  setGenericNameLocalized(
      escapeValue(getLocalizedValue(settings, locale, DESKTOP_KEY_GENERIC_NAME)
                      .toString()));
  setComment(escapeValue(
      getLocalizedValue(settings, locale, DESKTOP_KEY_COMMENT).toString()));
  setKeywords(
      getLocalizedValue(settings, locale, DESKTOP_KEY_KEYWORDS).toString());
  setExec(escapeValue(settings.value(DESKTOP_KEY_EXEC).toString()));
  setPath(escapeValue(settings.value(DESKTOP_KEY_PATH).toString()));
  setIcon(QString("image://appicon/%1")
              .arg(getLocalizedValue(settings, locale, DESKTOP_KEY_ICON)
                       .toString()));
  setType(settings.value(DESKTOP_KEY_TYPE).toString());
  setVersion(settings.value(DESKTOP_KEY_VERSION).toString());
  setCategories(getLocalizedValue(settings, locale, DESKTOP_KEY_CATEGORIES)
                    .toStringList());
  // Force set Ignored if its in our ignore list
  setIsIgnored((ignoredApps.indexIn(fileName()) != -1) ||
               (ignoredApps.indexIn(exec()) != -1));

  // Precalculate search string for filtering
  m_searchTerms.clear();
  m_searchTerms.append(name());
  m_searchTerms.append(nameLocalized());
  m_searchTerms.append(genericName());
  m_searchTerms.append(genericNameLocalized());
  m_searchTerms.append(comment());
  m_searchTerms.append(keywords());
  m_searchTerms.append(exec());
  emit searchTermsChanged(m_searchTerms);

  return true;
}

bool Application::build() {

  // ONLY For Testing right now
  setName("Dummy Test Application");
  setNameLocalized("Dummy Test Application");
  setGenericName("Dummy Test Application");
  setGenericNameLocalized("Dummy Test Application");
  setComment("This is just for testing adding new element");
  setKeywords("");
  setExec("/test/path/to/exec/file");
  setPath("");
  setIcon(QString("image://appicon/Icon_demo_industry.svg"));
  setType("");
  setVersion("1.0");
  //setCategories("Test".toStringList());
  // Force set Ignored if its in our ignore list
  setIsIgnored(false);
  return true;
}

void Application::startApplication(void) {
  // Strip field codes from Exec= line
  QString stripped = this->exec().remove(QRegExp("%[a-zA-Z]")).trimmed();
  QStringList args = QProcess::splitCommand(stripped);
  QString command = args.takeFirst();
  DEBUG_MSG("Starting process: " << command << " args: " << args.join(','));
  QProcess::startDetached(command, args);
  DEBUG_MSG("Bye bye :)");
}

bool Application::run(QString input) {
  DEBUG_MSG("Executing: " << exec() << " With Input: " << input);
  uint32_t index = input.toInt();
  bool success = false;
  static QString errorString = "";

  // Clear message error
  errorString.clear();

  if(m_appProcess) {
    errorString.append("Can't start a new process while another one is running!");
    DEBUG_MSG(errorString);
    return false;
  }

  // Strip field codes from Exec= line
  static QRegularExpression re("%[a-zA-Z]");
  QString stripped = exec().remove(re).trimmed();
  if (stripped.size() > 0) {
    QStringList args = QProcess::splitCommand(stripped);
    QString command = args.takeFirst();
    QString fileName(command);
    QFile file(fileName);
    if(file.exists()) {
        DEBUG_MSG("Starting process: " << command << " args: " << args.join(','));
        m_appProcess = new QProcess();
        if(m_appProcess) {
            qRegisterMetaType<QProcess::ExitStatus>("QProcess::ExitStatus"); // new line

            connect(m_appProcess,
                    (void(QProcess::*)(int, QProcess::ExitStatus)) & QProcess::finished, this,
                    [this](int exitCode, QProcess::ExitStatus exitStatus) { this->processExited(exitCode, exitStatus); },
                    Qt::DirectConnection);
            connect(m_appProcess, &QProcess::errorOccurred, this, &Application::processError, Qt::BlockingQueuedConnection);
            connect(m_appProcess, &QProcess::started, this, &Application::processRunning, Qt::DirectConnection);

            m_appProcess->start(command, args);
            errorString.append("No Error");
            success = true;
        } else {
            errorString.append("Failed to create a Process for given Command!");
        }
    } else {
        errorString.append("Program not found in system path!");
    }
  } else {
    errorString.append("Invalid Command!");
  }

  if (!success) {
    DEBUG_MSG(errorString);
    emit AppError(errorString, index);
  }

  return true; // Just to make the compiler happy ...
}

QString Application::fileName() const { return m_fileName; }

QString Application::name() const { return m_name; }

QString Application::nameLocalized() const { return m_nameLocalized; }

QString Application::genericName() const { return m_genericName; }

QString Application::genericNameLocalized() const {
  return m_genericNameLocalized;
}

QString Application::comment() const { return m_comment; }

QString Application::keywords() const { return m_keywords; }

QString Application::exec() const { return m_exec; }

QString Application::tryExec() const { return m_tryExec; }

QString Application::path() const { return m_path; }

QString Application::icon() const { return m_icon; }

QString Application::type() const { return m_type; }

QString Application::version() const { return m_version; }

QStringList Application::categories() const { return m_categories; }

QStringList Application::searchTerms() const { return m_searchTerms; }

void Application::setFileName(QString fileName) {
  if (m_fileName == fileName)
    return;
  m_fileName = fileName;
  emit fileNameChanged(fileName);
}

void Application::setName(QString name) {
  if (m_name == name)
    return;

  m_name = name;
  emit nameChanged(name);
}

void Application::setNameLocalized(QString nameLocalized) {
  if (m_nameLocalized == nameLocalized)
    return;

  m_nameLocalized = nameLocalized;
  emit nameLocalizedChanged(nameLocalized);
}

void Application::setGenericName(QString genericName) {
  if (m_genericName == genericName)
    return;

  m_genericName = genericName;
  emit genericNameChanged(genericName);
}

void Application::setGenericNameLocalized(QString geneircNameLocalized) {
  if (m_genericNameLocalized == geneircNameLocalized)
    return;

  m_genericNameLocalized = geneircNameLocalized;
  emit genericNameLocalizedChanged(geneircNameLocalized);
}

void Application::setComment(QString comment) {
  if (m_comment == comment)
    return;

  m_comment = comment;
  emit commentChanged(comment);
}

void Application::setKeywords(QString keywords) {
  if (m_keywords == keywords)
    return;

  m_keywords = keywords;
  emit keywordsChanged(keywords);
}

void Application::setExec(QString exec) {
  if (m_exec == exec)
    return;

  m_exec = exec;
  emit execChanged(exec);
}

void Application::setTryExec(QString tryExec) {
  if (m_tryExec == tryExec)
    return;

  m_tryExec = tryExec;
  emit tryExecChanged(tryExec);
}

void Application::setPath(QString path) {
  if (m_path == path)
    return;
  m_path = path;
  emit pathChanged(path);
}

void Application::setIcon(QString icon) {
  if (m_icon == icon)
    return;

  m_icon = icon;
  emit iconChanged(icon);
}

void Application::setType(QString type) {
  if (m_type == type)
    return;

  m_type = type;
  emit typeChanged(type);
}

void Application::setVersion(QString version) {
  if (m_version == version)
    return;

  m_version = version;
  emit versionChanged(version);
}

void Application::setCategories(QStringList categories) {
  if (m_categories == categories)
    return;

  m_categories = categories;
  emit categoriesChanged(categories);
}

void Application::setSearchTerms(QStringList searchTerms) {
  if (m_searchTerms == searchTerms)
    return;
  m_searchTerms = searchTerms;
  emit searchTermsChanged(searchTerms);
}

void Application::setIsIgnored(bool isIgnored) {
  if (m_isIgnored == isIgnored)
    return;

  m_isIgnored = isIgnored;
  emit isIgnoredChanged(isIgnored);
}

bool Application::isIgnored() const { return m_isIgnored; }

QVariant Application::getLocalizedValue(QSettings &settings, QString locale,
                                        QString key) {
  QString localizedKey = key;
  QVariant value = settings.value(localizedKey.append("[%1]").arg(locale));
  if (value.toString().isEmpty())
    return settings.value(key);
  return value;
}

QString Application::escapeValue(QString value) {
  // http://standards.freedesktop.org/desktop-entry-spec/latest/ar01s03.html
  QString result;
  bool inEscapeSeq = false;
  for (auto chr : value) {
    if (inEscapeSeq) {
      // ++it; // Next char
      if (chr == 's')
        result.append(' '); // Space
      else if (chr == 'n')
        result.append('\n'); // New line
      else if (chr == 'r')
        result.append('\r'); // CR
      else if (chr == 't')
        result.append('\t'); // Tab
      else if (chr == '\\')
        result.append('\\'); // Backslash
      inEscapeSeq = false;
    } else if (chr == '\\')
      inEscapeSeq = true; // Backslash, start escape sequence
    else
      result.append(chr);
  }
  return result;
}

bool Application::testFile() {
  if (tryExec().isEmpty())
    return true;
  QStringList pathList =
      QString(getenv("PATH")).split(":");     // Get PATH from environment
  for (const auto &path : qAsConst(pathList)) // Loop over paths from PATH
    if (QFile::exists(QString(path).append("/").append(tryExec())))
      return true; // If found return true
  return false;    // Fallthrough: TryExec was set but file not found on PATH
}

void Application::processExited(int exitCode, QProcess::ExitStatus exitStatus) {
  UNUSED(exitCode);
  UNUSED(exitStatus);
  if(m_appProcess) {
    DEBUG_MSG("Process Exited");
    emit AppRunning(false, &m_appProcess);
  }
}

void Application::processError() {
  if(m_appProcess) {
    // Wait for the process to gracefully finish before deleting the pointer!
    m_appProcess->waitForFinished(-1);
    DEBUG_MSG("Process Error!");
    m_appProcess->deleteLater();
    delete m_appProcess;
    m_appProcess = 0;
    emit AppError("Process Error!", 0);
  }
}

void Application::processRunning() {
  if(m_appProcess) {
    DEBUG_MSG("Process Is Running!");
    emit AppRunning(true, &m_appProcess);
  }
}

void Application::exitProcess() {
  if(m_appProcess) {
    DEBUG_MSG("Process about to exit");
    m_appProcess->kill();
    // After this statement the m_appProcess pointer is invalid!
  }
}
