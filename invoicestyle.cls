% !TEX root = invoice.tex

\ProvidesClass{invoicestyle}
\LoadClass[12pt]{article}


%----------------------------------------------------------------------------------------
%	Font Definition
%----------------------------------------------------------------------------------------

\usepackage{ifxetex}
\usepackage{ifluatex}
\usepackage{eurosym}
\newif\ifmodernTeX
\modernTeXfalse
\ifluatex
  \modernTeXtrue
\fi
\ifxetex
  \modernTeXtrue
\fi

\ifmodernTeX
\usepackage{fontspec}
\defaultfontfeatures{Ligatures=TeX}

\setmainfont[
      BoldFont=LinLibertineOZ,
      BoldItalicFont=LinLibertineOZI,
      SmallCapsFont=LinLibertineO,
      SmallCapsFeatures={Letters=SmallCaps},
]{LinuxLibertineO}

\newfontfamily\spacedFont[LetterSpace=2.0]{LinuxLibertineO}

\newfontfamily\displayFont[Extension=.otf,
      BoldFont=LinLibertine_DR,%fake
      ItalicFont=LinLibertine_DR,%fake
      BoldItalicFont=LinLibertine_DR,%fake
      ]{LinLibertine_DR}

\setsansfont[Extension=.otf,
      BoldFont=LinBiolinum_RB,
      ItalicFont=LinBiolinum_RI,
      BoldItalicFont=LinBiolinum_RB,% fake
      SmallCapsFont=LinBiolinum_R,
      SmallCapsFeatures={Letters=SmallCaps},
      ]{LinBiolinum_R}

\setmonofont[Extension=.otf]{Inconsolata}

\else

\let\spacedFont\relax
\let\displayFont\relax

\fi


\usepackage[german]{babel}
\usepackage[norule]{footmisc}
\usepackage[parfill]{parskip} % Do not indent paragraphs
\usepackage[pdfencoding=auto,unicode, bookmarks=false, colorlinks=false, pdfborder={0 0 0},pdftitle={Invoice from XXX}, pdfauthor={XXX}, pdfsubject={Invoice}, pdfkeywords={Invoice, XXX}]{hyperref}
\usepackage[table]{xcolor}
\usepackage[top=1.5cm, bottom=1.5cm, left=2cm, right=2cm]{geometry}
\usepackage{array}
\usepackage{calc} % Counters for totaling hours and cost
\usepackage{eurosym}
\usepackage{fp} % Fixed-point arithmetic
\usepackage{longtable}
\usepackage{multicol}
\usepackage{tabu}

\pagestyle{empty}

%----------------------------------------------------------------------------------------
%	Colors
%----------------------------------------------------------------------------------------

\colorlet{headcolor}{gray!21}
\colorlet{tablecolor1}{gray!4}
\colorlet{tablecolor2}{gray!11}
\colorlet{footnotegray}{gray!90}


%----------------------------------------------------------------------------------------
%	Definitions
%----------------------------------------------------------------------------------------

% Counters for totaling up hours and dollars
\newcounter{hours}
\newcounter{subhours}
\newcounter{cost}
\newcounter{subcost}
\setcounter{hours}{0}
\setcounter{subhours}{0}
\setcounter{cost}{0}
\setcounter{subcost}{0}

% the right shift of the right blocks
\xdef\rightalignment{11cm}

\title{Rechnungsübersicht}
\date{\today }


% footnote style
\def\footnotestyle#1{%
  {\textsf{\color{footnotegray}\fontsize{3mm}{0mm}\selectfont #1}}%
}

\makeatletter
\let\thetitle\@title
\makeatother

% change color of footnote marks
\makeatletter
\renewcommand\@makefntext[1]{%
  \parindent 1em\noindent
  \hb@xt@1.8em{%
  \hss\@textsuperscript{\normalfont\color{footnotegray}\@thefnmark}}#1}
\makeatother


%----------------------------------------------------------------------------------------
%	Commands
%----------------------------------------------------------------------------------------

% Command for setting a default hourly rate
\newcommand{\feetype}[1]{
  \\
  \textbf{#1}
  \\
}

\newcommand{\invoiceheader}[1]{
\parbox[b][2cm][t]{\rightalignment}{{\color{gray!95}\displayFont\fontsize{1.5cm}{1.5cm}\selectfont\vbox to 1cm
    {\vss \companyname{}}}
    \vskip 3mm%
    {\fontsize{0.44cm}{0.5cm} \emph{\companysubtitle{}}}
}%
\kern 30mm
\parbox[b][2cm][t]{0.35\textwidth}{\ttfamily {{\color{gray!95}\fontsize{1.5cm}{1.5cm}\selectfont %
    \vbox to 1cm{\vss \leavevmode \kern -1mm Rechnung}}}
}

\kern -7mm

\leavevmode\kern 14cm \parbox{0.35\textwidth}{\ttfamily N\textsuperscript{o} {#1}\\
    \today }
}

\newcommand{\invoicetoadress}[3]{
    \begin{minipage}[t]{0.5\textwidth}
        \vskip 10mm
        {#1}\\
        {#2}\\
        {#3}\\
    \vspace*{-3mm}%
\end{minipage}
}


% Formats inputed number with 2 digits after the decimal place
\newcommand*{\formatNumber}[1]{\FPround{\cost}{#1}{2}\cost} %

% Returns the total of counter
\newcommand*{\total}[1]{\FPdiv{\t}{\arabic{#1}}{1000}\formatNumber{\t}}

% Create an invoice table
\newenvironment{invoiceTable}{
    \vskip 2cm
    \begin{center}
    {\ttfamily\LARGE \thetitle}

    \rule{6cm}{0.25pt}
\end{center}

    % Create a new row from title, unit quantity, unit rate, and unit name
    \newcommand*{\unitrow}[4]{%
         \addtocounter{cost}{1000 * \real{##2} * \real{##3}}%
         \addtocounter{subcost}{1000 * \real{##2} * \real{##3}}%
         ##1 & \formatNumber{##2} ##4 & \formatNumber{##3} \euro & \FPmul{\cost}{##2}{##3}\formatNumber{\cost} \euro%
         \\
    }
    % Create a new row from title and expense amount
    \newcommand*{\feerow}[2]{%
         \addtocounter{cost}{1000 * \real{##2}}%
         \addtocounter{subcost}{1000 * \real{##2}}%
         ##1 & & \formatNumber{##2} \euro & \FPmul{\cost}{##2}{1}\formatNumber{\cost} \euro%
         \\
    }

    \newcommand{\subtotalNoStar}{
        {\bf Zwischensumme} & {\bf \total{subhours} Stunden} &  & {\bf \total{subcost} \euro}
        \setcounter{subcost}{0}
        \setcounter{subhours}{0}
        \\*[1.5ex]
    }
    \newcommand{\subtotalStar}{
        {\bf Zwischensumme} & & & {\bf \total{subcost} \euro}
        \setcounter{subcost}{0}
        \\*[1.5ex]
    }
    \newcommand{\subtotal}{
         \hline
         \@ifstar
         \subtotalStar%
         \subtotalNoStar%
    }

    % Create a new row from date and hours worked (use stored fee type and hourly rate)
    \newcommand*{\hourrow}[3]{%
        \addtocounter{hours}{1000 * \real{##2}}%
        \addtocounter{subhours}{1000 * \real{##2}}%
        \unitrow{##1}{##2}{##3}{h}%
    }
    \renewcommand{\tabcolsep}{2.8ex}
    \setlength\LTleft{0pt}
    \setlength\LTright{0pt}
%     \rowcolors{1}{gray!25}{gray!4}
    \begin{longtable}{@{\extracolsep{\fill}\hspace{\tabcolsep}} l r r r }
%     \begin{longtable}{ l r r r }
    \hline
    {\bf Beschreibung der Leistungen} & \multicolumn{1}{r}{\bf Menge} & \multicolumn{1}{r}{\bf Einzelpreis} & \multicolumn{1}{r}{\bf Summe} \\*
    \hline\hline
    \endhead
}{
    \\
    \hline\hline\hline\\
    {\bf Gesamtbetrag} & & & {\bf \total{cost} \euro} \\
    \hline
    \hline

    \end{longtable}
}


\newcommand{\invoicefooter}{
    \vfill
    \small

    \setlength{\columnsep}{1.5cm}
    \begin{multicols}{2}
        \noindent\companyname{}\\
        Steuer-ID {\small \taxid{}}\\
        \hbox to 1cm{Adr\,:\hss} \companyaddress{}\\
        \hbox to 1cm{Tel\,:\hss} \companytel{}\\
        \hbox to 1cm{Mail\,:\hss} \href{mailto:\companyemail}{\companyemail}\\
        \hbox to 1.8cm{Kontonr.\,:\hss} \kontonr{}\\
        \hbox to 1.8cm{BLZ\,:\hss} \blz{}\\
        \hbox to 1.8cm{IBAN\,:\hss} \bankiban{}\\
        \hbox to 1.8cm{BIC\,:\hss} \bankbic{}
    \end{multicols}
\long\xdef\conditions{ }
\footnotestyle{\textbf{Zahlungsbedingungen:} Bitte überweisen Sie innerhalb von 14 Tagen den Gesamtbetrag von \total{cost} \euro \ auf das obige Konto}
}
