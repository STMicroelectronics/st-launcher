#ifndef APPLICATIONFILTER_H
#define APPLICATIONFILTER_H

#include <QObject>
#include <QSortFilterProxyModel>

class ApplicationFilter : public QSortFilterProxyModel {
  Q_OBJECT
  QString m_filter_name;
  bool m_show_ignored;

public:
  explicit ApplicationFilter(QObject *parent = nullptr);

  Q_INVOKABLE QObject *get(QModelIndex index);
  Q_INVOKABLE bool remove(QModelIndex index);
  Q_INVOKABLE bool add_new(QString filePath);
  Q_INVOKABLE bool run_app(QModelIndex index);

  QString filterName() const { return m_filter_name; }
  Q_INVOKABLE void setFilterName(QString filter);
  Q_INVOKABLE void setFilterShowIgnored(bool showIgnored);
  Q_INVOKABLE void toggleFilterShowIgnored();

protected:
  bool filterAcceptsRow(int sourceRow,
                        const QModelIndex &sourceParent) const override;
  bool lessThan(const QModelIndex &left,
                const QModelIndex &right) const override;
};

#endif // APPLICATIONFILTER_H
