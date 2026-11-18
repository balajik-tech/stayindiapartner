import os
import re
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_number(num_pages)
            super().showPage()
        super().save()

    def draw_page_number(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#666666"))

        # Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(54, 750, "Stay India Owner — Knowledge Transfer & Technical Documentation")
            self.setStrokeColor(colors.HexColor("#E0E0E0"))
            self.setLineWidth(0.5)
            self.line(54, 742, 558, 742)

        # Footer
        text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(558, 36, text)
        self.drawString(54, 36, "CONFIDENTIAL — FOR INTERNAL DEVELOPER KT ONLY")
        self.setStrokeColor(colors.HexColor("#E0E0E0"))
        self.setLineWidth(0.5)
        self.line(54, 48, 558, 48)

        self.restoreState()

def build_pdf(md_filepath, pdf_filepath):
    doc = SimpleDocTemplate(
        pdf_filepath,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=64,
        bottomMargin=64
    )

    styles = getSampleStyleSheet()

    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=22,
        leading=26,
        textColor=colors.HexColor("#16539B"),
        spaceAfter=10
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor("#555555"),
        spaceAfter=20
    )

    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=colors.HexColor("#16539B"),
        spaceBefore=16,
        spaceAfter=8,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'SectionH2',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor("#222222"),
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True
    )

    h3_style = ParagraphStyle(
        'SectionH3',
        parent=styles['Heading3'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=14,
        textColor=colors.HexColor("#333333"),
        spaceBefore=8,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor("#2C2C2C"),
        spaceAfter=6
    )

    bullet_style = ParagraphStyle(
        'BulletText',
        parent=body_style,
        leftIndent=15,
        spaceAfter=4
    )

    code_style = ParagraphStyle(
        'CodeBlock',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#1E293B"),
        backColor=colors.HexColor("#F1F5F9"),
        borderColor=colors.HexColor("#CBD5E1"),
        borderWidth=0.5,
        borderPadding=6,
        spaceBefore=6,
        spaceAfter=8
    )

    tbl_header_style = ParagraphStyle(
        'TblHeader',
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11,
        textColor=colors.white
    )

    tbl_body_style = ParagraphStyle(
        'TblBody',
        fontName='Helvetica',
        fontSize=8,
        leading=10.5,
        textColor=colors.HexColor("#1E293B")
    )

    story = []

    with open(md_filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    in_code_block = False
    code_lines = []
    in_table = False
    table_rows = []

    def escape_text(text):
        text = text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', text)
        text = re.sub(r'`(.*?)`', r'<font name="Courier" color="#16539B">\1</font>', text)
        return text

    i = 0
    while i < len(lines):
        line = lines[i].rstrip('\r\n')

        # Code blocks
        if line.startswith('```'):
            if in_code_block:
                # Flush code block
                code_text = "<br/>".join([escape_text(cl) for cl in code_lines])
                story.append(Paragraph(code_text, code_style))
                code_lines = []
                in_code_block = False
            else:
                in_code_block = True
                code_lines = []
            i += 1
            continue

        if in_code_block:
            code_lines.append(line)
            i += 1
            continue

        # Tables
        if '|' in line and line.strip().startswith('|'):
            if not in_table:
                in_table = True
                table_rows = []

            # Check if separator row
            if '---' in line:
                i += 1
                continue

            cells = [c.strip() for c in line.strip('|').split('|')]
            table_rows.append(cells)
            i += 1
            continue
        else:
            if in_table:
                # Flush table
                if table_rows:
                    formatted_table = []
                    # Header
                    hdr = [Paragraph(escape_text(c), tbl_header_style) for c in table_rows[0]]
                    formatted_table.append(hdr)
                    for r in table_rows[1:]:
                        row_cells = [Paragraph(escape_text(c), tbl_body_style) for c in r]
                        formatted_table.append(row_cells)

                    # Determine col widths
                    col_count = len(table_rows[0])
                    avail_width = 504 # 612 - 108
                    col_widths = [avail_width / col_count] * col_count
                    if col_count == 3:
                        col_widths = [100, 180, 224]
                    elif col_count == 5:
                        col_widths = [55, 145, 124, 90, 90]
                    elif col_count == 2:
                        col_widths = [180, 324]

                    t = Table(formatted_table, colWidths=col_widths)
                    t.setStyle(TableStyle([
                        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#16539B")),
                        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
                        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
                        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
                        ('TOPPADDING', (0, 0), (-1, -1), 5),
                        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
                        ('LEFTPADDING', (0, 0), (-1, -1), 5),
                        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
                    ]))
                    story.append(t)
                    story.append(Spacer(1, 8))
                in_table = False
                table_rows = []

        # Empty line
        if not line.strip():
            i += 1
            continue

        # Horizontal Rule
        if line.strip() == '---':
            story.append(HRFlowable(width="100%", thickness=0.8, color=colors.HexColor("#CBD5E1"), spaceBefore=10, spaceAfter=10))
            i += 1
            continue

        # Headings
        if line.startswith('# '):
            story.append(Paragraph(escape_text(line[2:]), title_style))
            story.append(Paragraph("Comprehensive Developer Knowledge Transfer (KT) & Architecture Specification Manual", subtitle_style))
        elif line.startswith('## '):
            story.append(Spacer(1, 6))
            story.append(Paragraph(escape_text(line[3:]), h1_style))
        elif line.startswith('### '):
            story.append(Paragraph(escape_text(line[4:]), h2_style))
        elif line.startswith('#### '):
            story.append(Paragraph(escape_text(line[5:]), h3_style))
        elif line.startswith('- ') or line.startswith('* '):
            story.append(Paragraph(f"• {escape_text(line[2:])}", bullet_style))
        elif re.match(r'^\d+\.\s', line):
            text = re.sub(r'^\d+\.\s', '', line)
            story.append(Paragraph(f"• {escape_text(text)}", bullet_style))
        else:
            story.append(Paragraph(escape_text(line), body_style))

        i += 1

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF successfully generated at: {pdf_filepath}")

if __name__ == '__main__':
    md_path = "/Users/balajik/Desktop/STAY INDIA/Projects/Stay-India-Owner/PROJECT_DOCUMENTATION.md"
    pdf_path = "/Users/balajik/Desktop/STAY INDIA/Projects/Stay-India-Owner/PROJECT_DOCUMENTATION.pdf"
    build_pdf(md_path, pdf_path)
