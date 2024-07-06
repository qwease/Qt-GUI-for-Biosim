#ifndef PARAMINPUT_H
#define PARAMINPUT_H

#include <QLineEdit>

class ParamInput : public QLineEdit
{
    Q_OBJECT

public:
    ParamInput(QObject *parent = nullptr);
signals:
    void editingFinished(ParamInput & paramInput);
};

#endif // PARAMINPUT_H
