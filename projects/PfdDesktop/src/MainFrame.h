#pragma once

#include "framework.h"

class CMainFrame final : public CFrameWnd
{
public:
  CMainFrame();

protected:
  afx_msg void OnPaint();
  DECLARE_MESSAGE_MAP()
};
