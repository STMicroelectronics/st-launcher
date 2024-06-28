#include "ApplicationFilter.h"
#include "ApplicationList.h"
#include "IconeProvider.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QScreen>
#include <QtQml>

#include "PlatformData.h"

int main(int argc, char *argv[]) {
  qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
  qputenv("QT_VIRTUALKEYBOARD_DESKTOP_DISABLE", QByteArray("1"));

  QLoggingCategory::setFilterRules(
      "qt.svg.warning=false"); // Hide buggy SVG icon warnings
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
  QCoreApplication::setApplicationName("stlauncher");
  QCoreApplication::setOrganizationName("STMicroelectronics");
  QCoreApplication::setOrganizationDomain("st.com");

  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;
  QQmlContext *context = engine.rootContext();

  ApplicationList *applications = new ApplicationList(app.parent());
  ApplicationFilter *apps = new ApplicationFilter(app.parent());

  QScreen *primaryScreen = QGuiApplication::primaryScreen();
  if (!primaryScreen)
    qFatal("Cannot determine the primary screen");

  const bool force_landscape_ui = [&]() {
    return false; // The launcher support Portrait orientation anyway!
  }();
  const int dispWidth = [&]() {
#ifndef Q_OS_WINDOWS
    QSize primaryGeometry = primaryScreen->size();
    return primaryGeometry.width();
#else
    return 1024;
#endif
  }();
  const int dispHeight = [&]() {
#ifndef Q_OS_WINDOWS
    QSize primaryGeometry = primaryScreen->size();
    return primaryGeometry.height();
#else
    return 600;
#endif
  }();

  PlatformData *platformData = new PlatformData();

  engine.rootContext()->setContextProperty("platformdata", platformData);
  engine.rootContext()->setContextProperty(
      "_force_landscape_ui", QVariant::fromValue(force_landscape_ui));
  engine.rootContext()->setContextProperty("_windowWidth",
                                           QVariant::fromValue(dispWidth));
  engine.rootContext()->setContextProperty("_windowHeight",
                                           QVariant::fromValue(dispHeight));
  engine.rootContext()->setContextProperty("qtversion", QString(qVersion()));

  apps->setSourceModel(applications);
  apps->sort(0, Qt::AscendingOrder);
  apps->setDynamicSortFilter(true);
  apps->setSortLocaleAware(true);
  context->setContextProperty("apps", apps);

  const QUrl url(QStringLiteral("qrc:/qml/content/App.qml"));
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreated, &app,
      [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
          QCoreApplication::exit(-1);
      },
      Qt::QueuedConnection);
  engine.addImageProvider(QLatin1String("appicon"), new IconProvider);
  engine.addImportPath(QStringLiteral("qrc:/qml/"));
  engine.addImportPath("qrc:/qml/imports/"); // Adding imports paths
  engine.addImportPath("qrc:/qml/content/"); // Adding imports paths
  engine.load(url);

  if (engine.rootObjects().isEmpty())
    return -1;

  QObject *topLevel = engine.rootObjects().value(0);
  QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
  QObject::connect(applications, SIGNAL(runningChanged(QVariant)),
                   window, SLOT(runningChanged(QVariant)));
  QObject::connect(applications, SIGNAL(readyChanged(QVariant)), window,
                   SLOT(readyChanged(QVariant)));
  QObject::connect(applications, SIGNAL(errorMessageChanged(QVariant)), window,
                   SLOT(errorMessageChanged(QVariant)));

  QObject* loader = engine.rootObjects().constFirst()->findChild<QObject*>("LoaderObject");
  QObject::connect(loader, SIGNAL(sendErrorMessage(QString,int)), applications, SLOT(appErrorSlot(QString,int)));
  //QObject::connect(applications, SIGNAL(appErrorSignal(QString,int)), loader, SIGNAL(getErrorMessage(QString,int)));

  QObject::connect(&app, SIGNAL(aboutToQuit()), applications, SLOT(exitHandler()));

  return app.exec();
}
