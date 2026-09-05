#include "PfdDesktop.h"

#include "MainFrame.h"

CPfdDesktopApp the_app;

BOOL CPfdDesktopApp::InitInstance()
{
  CWinApp::InitInstance();

  auto *const main_frame = new CMainFrame();
  if (main_frame->GetSafeHwnd() == nullptr)
  {
    delete main_frame;
    return FALSE;
  }

  m_pMainWnd = main_frame;
  main_frame->ShowWindow(SW_SHOW);
  main_frame->UpdateWindow();
  return TRUE;
}
