#include "systrayhelper.h"

void SystrayHelper::setRootWindow(QObject *rootObject)
{
    m_rootObject = rootObject;
}

SystrayHelper::SystrayHelper(QObject *parent) : QObject(parent)
{
}
