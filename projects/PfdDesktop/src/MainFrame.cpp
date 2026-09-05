#include "MainFrame.h"

#include "resource.h"

BEGIN_MESSAGE_MAP(CMainFrame, CFrameWnd)
    ON_WM_PAINT()
END_MESSAGE_MAP()

CMainFrame::CMainFrame()
{
    CString title;
    title.LoadString(IDS_APP_TITLE);
    Create(nullptr, title, WS_OVERLAPPEDWINDOW, CRect(100, 100, 900, 550));
}

void CMainFrame::OnPaint()
{
    CPaintDC paint_dc(this);
    CRect client_area;
    GetClientRect(&client_area);

    CString greeting;
    greeting.LoadString(IDS_HELLO_TEXT);

    CFont font;
    font.CreatePointFont(180, L"Segoe UI");
    CFont* const previous_font = paint_dc.SelectObject(&font);
    paint_dc.SetBkMode(TRANSPARENT);
    paint_dc.DrawText(greeting, &client_area, DT_CENTER | DT_VCENTER | DT_SINGLELINE);
    paint_dc.SelectObject(previous_font);
}
