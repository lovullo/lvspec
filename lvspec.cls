% LoVullo Specification class

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{lvspec}
\RequirePackage{kvoptions}
\RequirePackage{kvoptions-patch}

\DeclareBoolOption{bw}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrreprt}}
\ProcessOptions\relax

% base class
\LoadClass{scrreprt}

\RequirePackage[top=3.5cm,bottom=5cm,width=\textwidth]{geometry}
\RequirePackage{makeidx}
\RequirePackage{minitoc}
\RequirePackage{titlesec}
\RequirePackage{hyperref}
\RequirePackage[usenames,dvipsnames]{xcolor}
\RequirePackage{url}
\RequirePackage{varioref}
\RequirePackage{amsmath}
\RequirePackage{multirow}

% default hyperlink color
\definecolor{hyperlink}{HTML}{000040}
% unless black and white
\iflvspec@bw
  \definecolor{hyperlink}{HTML}{000000}
\fi
\hypersetup{
  % get rid of box in older versions of hyperref
  colorlinks=true,
  linkcolor=hyperlink,
  citecolor=black,
  filecolor=black,
  urlcolor=blue,
  final % enable links in draft mode
}

% reduce section spacing after sections and before subsections (carefully
% balanced with \parskip below)
\titlespacing{\section}{0em}{1em plus 1em minus 0.5em}{0em plus 0.5em}
\titlespacing{\subsection}{0em}{0em plus 0.5em}{0em}
\titlespacing{\subsubsection}{0em}{0em plus 0.5em}{0em}

% remove indentation and provide flexible paragraph spacing (this style of
% display is more appropriate for paragraph numbering)
\parindent0ex
\parskip1em plus 0.2em minus 0.5em

% show subsubsection numbers
\setcounter{tocdepth}{4}
\setcounter{minitocdepth}{4}
\setcounter{secnumdepth}{4}

% the version string is taken directly from a file written by the build process
\def\@verstr{{\footnotesize\tt\input{verstr.tex}}}

\def\@oddhead{\small\sc\rightmark\hfill TODO}
\let\@evenhead\@oddhead
\def\@oddfoot{\S\thefullsection\hfill\thepage\hfill\@verstr}
\let\@evenfoot\@oddfoot

% section numbers will appear in the margin and the chapter number will be
% slightly enlarged
\titleformat{\chapter}
  {\huge\bfseries\sffamily}
  {\llap{{\Huge\thechapter}\hskip1ex}}
  {0em}
  {\aftergroup\minitoc\aftergroup\minilot\aftergroup\minilof}
\titleformat{\section}
  {\Large\bfseries\sffamily}
  {\llap{\thesection\hskip1ex}}
  {0em}
  {}
\titleformat{\subsection}
  {\large\bfseries\sffamily}
  {\llap{\thesubsection\hskip1ex}}
  {0em}
  {}
\titleformat{\subsubsection}
  {\normalsize\bfseries\sffamily}
  {\llap{\thesubsubsection\hskip1ex}}
  {0em}
  {}


% lazy
\let\@minitoc@orig\minitoc
\def\minitocoff{\gdef\minitoc{}}
\def\minitocon{\global\let\minitoc\@minitoc@orig}

% enable index generation
\makeindex


%%
% Paragraph numbering and example environment
%
\newcount\pn \newcount\pnn
\pn0\relax \pnn1\relax

\newcount\pne
\pne1\relax

\def\pnum{{%
  % never show paragraph numbers within an environment (LaTeX stores the name of
  % the current environment in @currenvir)
  \def\@@document{dwspec}%
  \def\@@premcalc{premcalc}%
  % allow dwspec by default
  \let\@@cmp\@currenvir
  % allow premcalc env
  \ifx\@currenvir\@@premcalc
    \let\@@cmp\@@document
  \fi
  % output if match
  \ifx\@@cmp\@@document%
    \ifx\haspnum1\relax
      \@margin@sig%
      \global\advance\pn1\relax%
      \global\advance\pnn1\relax%
      \global\pne0\relax%
      \ifvmode\leavevmode\fi%
      \llap{\the\pn. \,\,}%
    \fi
  \fi
}}

% margin area for paragraph signatures (initials)
\def\@margin@sig{%
  % if in draft mode, add a spot next to the paragraph for initials
  \ifdwspec@draft%
    \pnumoff%
    \marginpar{%
      \ifx\@@margin@sig@repl\empty%
        % generate signature line slightly below the line itself
        \underline{\hspace{3em}}%
        \ifx\@@margin@sig@dept\relax
          % one needs to be assigned
          \PackageWarning{dwspec}{missing authorization party in%
            \space\thechapter.\thesection}%
        \else
          \space{\scriptsize(\@@margin@sig@dept)}%
          % clear the department, if necessary
          \@margin@sig@cleardept
        \fi
      \else%
        % use custom line and clear it
        \@@margin@sig@repl%
        \if@keepsigtext\else
          \gdef\@@margin@sig@repl{}%
        \fi
      \fi%
    }%
    \pnumon%
  \fi%
}

% for use externally
\let\signline\@margin@sig
\def\sigkeep{\global\@keepsigtexttrue}
\def\sigunkeep{
  \global\@keepsigtextfalse
  \gdef\@@margin@sig@repl{}%
}

% optional replacement text for next signature line
\let\@@margin@sig@repl\relax
% department that should do the signing
\let\@@margin@sig@dept\relax

\newif\if@@sectiondept
\let\@@groupdept\relax

\def\@margin@sig@cleardept{%
  % do not clear if we're in a department group
  \ifx\@@groupdept\relax
    \global\let\@@margin@sig@dept\relax
  \fi
}

% specifies the department(s) that are the intended audience (applies for a
% single signature line)
\def\dept#1{%
  \def\@@margin@sig@dept{%
    \hyperref[s:authorize]{\uppercase{#1}}%
  }%
}
% indicates that an entire section applies to a given department (will be
% automatically cleared when a new section is encountered)
\def\sectiondept#1{%
  \dept{#1}%
  \@@sectiondepttrue
  \def\@@groupdept{}%
}
% applies a department until the group is closed (may be nested); will clear
% section grouping
\def\begindeptgroup#1{%
  \begingroup
  \dept{#1}%
  % using this def instead of an if boolean allows us to nest (will go out of
  % scope when the group is ended)
  \def\@@groupdept{}%
  % disable section grouping (to prevent clearing the department when a new
  % section is encountered)
  \@@sectiondeptfalse
}
\def\enddeptgroup{%
  \endgroup
}


% add paragraph numbering (we can't just set \everypar like we can in good 'ol
% TeX because LaTeX has its way with it)
\let\oldep\everypar
\let\haspnum0\relax
\let\hadpnum0\relax
\newtoks\everyparon
\newtoks\everyparoff
\def\pnumon{%
  \oldep{\the\everyparon\pnum}%
  \let\hadpnum\haspnum%
  \let\haspnum1%
}
\def\pnumoff{%
  \oldep{\the\everyparoff}%
  \let\hadpnum\haspnum%
  \let\haspnum0%
}
\def\pnumrest{%
  \ifx\hadpnum1\relax
    \pnumon%
  \else%
    \pnumoff%
  \fi%
}
% outputs what will be the next page number
\def\sinit{%
  \pn0\relax \pnn1\relax
  % clear any department sections, if necessary
  \if@@sectiondept
    \@@sectiondeptfalse
    \global\let\@@margin@sig@dept\relax
  \fi
}

\let\@chapterorig\chapter
\let\@sectionorig\section
\let\@subsectionorig\subsection
\let\@subsubsectionorig\subsubsection
\let\@footnoteorig\footnote
\let\@footnotetextorig\footnotetext

% override chapter/section macros (it is important not to do this until we are
% sure that nothing with use \chapter, as that formally does not accept an
% argument...we treat it as though it does in order to make life easier)
\def\@hgrab{
  \gdef\chapter##1{\pnumoff\@chapterorig{##1}\pnumrest\sinit}
  \gdef\section##1{\pnumoff\@sectionorig{##1}\pnumrest\sinit\smarkright{##1}}
  \gdef\subsection##1{\pnumoff\@subsectionorig{##1}\pnumrest\sinit\smarkright{##1}}
  \gdef\subsubsection##1{\pnumoff\@subsubsectionorig{##1}\pnumrest\sinit\smarkright{##1}}
  \gdef\footnote##1{\pnumoff\@footnoteorig{##1}\pnumrest}
  \gdef\footnotetext##1{\pnumoff\@footnotetextorig{##1}\pnumrest}
}

% restore headings
\def\@hrestore{
  \let\chapter\@chapterorig
  \let\section\@sectionorig
  \let\subsection\@subsectionorig
  \let\subsubsection\@subsubsectionorig
  \let\footnote\@footnoteorig
  \let\footnotetext\@footnotetextorig
}

\def\smarkright#1{\markright{\S\thefullsection~#1}}

% these may be used for included files that aren't sure what level of section
% nesting they may be included at
\def\nextsection{%
  \begingroup%
    \ifnum\value{subsubsection}>0\relax%
      \errmessage{Sorry; section nesting is too deep}%
    \else\ifnum\value{subsection}>0\relax%
      \aftergroup\subsubsection%
    \else\ifnum\value{section}>0\relax%
      \aftergroup\subsection%
    \else%
      \aftergroup\section%
    \fi\fi\fi%
  \endgroup%
}


% outputs the full section number, regardless of current depth
\def\thefullsection{%
  \ifnum\value{subsubsection}>0\relax%
    \thesubsubsection%
  \else\ifnum\value{subsection}>0\relax%
    \thesubsection%
  \else\ifnum\value{section}>0\relax%
    \thesection%
  \else%
    \thechapter%
  \fi\fi\fi%
}
\def\thepne{\ifnum\the\pne>1\relax-\the\pne\fi}

\newenvironment{ex}%
  {%
    \goodbreak%
    \global\advance\pne1\relax%
    \list{}{%
      \leftmargin4ex
      \item\relax
      \small%
    }%
    {\bf Example \thefullsection-\the\pn\thepne:\space}%
    \ignorespaces
  }%
  {%
      $\square$
    \endlist
    \par
    \goodbreak
  }


%%
% Common macros
%
\def\shall {Shall }
\def\shallnot {Shall Not }
\def\must {Must }
\def\mustnot {Must Not }
\def\may {May }
\def\exempt {Exempt }
\def\unspecified{Unspecified}
\AtBeginDocument{%
  % this guy causes problems with some macros that make the poor choice of using
  % \undefined to represent a macro that is, well, not defined
  \gdef\undefined{Undefined}
}

% formatting
\def\dt#1{%
  \goodbreak%
  \@dt@idx#1;||%
  \item[#1]\hfill\\%
  % display signature area in margin
  \@margin@sig%
  % get rid of mysterious magical hspace that appears from the marginpar
  \hskip-1ex\relax%
}
\def\dfn#1{{\sl\@idxhat@idx{#1}\/}}
\def\rfc#1{{\tt RFC #1}}
\def\hex#1{{\tt 0x#1}}
\def\code#1{{\tt#1}}
\def\func#1{{\tt #1()}}
\def\set#1{%
  \ifmmode%
    \left\{#1\right\}%
  \else%
    $\set{#1}$%
  \fi%
}

% non-technical-reader-friendly if not in math mode
\def\true{\ifmmode\top\else Yes\fi}
\def\false{\ifmmode\bot\else No\fi}

\def\vecset#1{%
  \ifmmode%
    \left[\,#1\,\right]%
  \else%
    $\vecset{#1}$%
  \fi%
}

\def\todo#1{{\sc Todo: \it#1\/}}

% trim a single space from the left, if present
\def\@triml#1{\ifx#1\ \else#1\fi}
% trim all spaces at the right, if present
\def\@trimr#1 |||{#1}

% properly adds semicolon-delimited terms to the index
\def\@dt@idx#1;#2||{%
  \def\@second{#2}%
  \index{\@triml#1}%
  % recurse if we have more
  \ifx\@second\empty\else%
    % will already having a trailing semi-colon, so do not re-add
    \@dt@idx#2||
  \fi%
}

% refs
\def\fref#1{Figure~\ref{f:#1} on page~\pageref{f:#1}}
\def\tref#1{Table~\ref{t:#1} on page~\pageref{t:#1}}
\def\sref#1{\S\vref*{s:#1}}
\def\srefnopg#1{\S\ref{s:#1}}
\def\srefrange#1#2{\S\vrefrange{s:#1}{s:#2}}
\def\srefpagerange#1#2{\vpagerefrange*{s:#1}{s:#2}}
\let\Sref\sref
\def\p#1{%
  % define pref and prefp macros that store, respectively, the section number
  % and page number (for example, if #1=foo, then this will create pref@foo and
  % prefp@foo); note that this is used before a paragraph begins, so we increase
  % the paragraph number by one before storing it
  \label{@pref:#1}
  \expandafter\xdef\csname pref@#1\endcsname{\thefullsection-\the\pnn}
  \expandafter\xdef\csname prefp@#1\endcsname{\thepage}
}
% TODO: forward references
\def\pref#1{%
  \P\hyperref[@pref:#1]{\csname pref@#1\endcsname}%
  % only output the page number if it is not the current page (we decrease the
  % current page number by 1 to account for the fact that the page number may be
  % off by one due to page box calculations; this consequently means that we may
  % not display the page number on a following page, which should be fine)
  \newcount\@@thepage \@@thepage\thepage \advance\@@thepage-1
  \expandafter\let\expandafter\@pg\csname prefp@#1\endcsname
  \ifx\@pg\relax\else
    \ifnum\@@thepage>\@pg\relax%
      \space on page~\pageref{@pref:#1}%
    \fi
  \fi
}

\newif\if@keepsigtext
\@keepsigtextfalse

% denotes incomplete sections/paragraphs
\def\@incomplete@default{{\small\bf Incomplete.}}
\def\incomplete{%
  \gdef\@@margin@sig@repl{\@incomplete@default}%
}
\def\incompletei{%
  \gdef\@@margin@sig@repl{%
    \@incomplete@default\\%
    \begingroup
      \scriptsize
      \space(Need more info%
      \ifx\@@margin@sig@dept\relax\else
        \space from\space\@@margin@sig@dept%
        % clear the department, if necessary
        \@margin@sig@cleardept
      \fi
      .)%
    \endgroup
  }%
}%


%%
% idxhat (index)
%
\def\@idxhat#1{%
  \begingroup%
    \ifmmode\@hat#1\else%
      \ifx#1[%
        \aftergroup\@idxhat@contained%
      \else
        \aftergroup\@idxhat@term%
      \fi%
      \aftergroup#1%
    \fi%
  \endgroup%
}
% term ends at the first space
\def\@idxhat@term#1 {\@idxhat@idx{#1} }
% grouped in [square brackets]
\def\@idxhat@contained[#1]{\@idxhat@idx{#1}}
\def\@idxhat@idx#1{\index{#1}\@idxhat@tail#1!||}
% strips all parents
\def\@idxhat@tail#1!#2||{%
  % we're done once #2 is empty
  \def\@chk{#2}%
  \ifx\@chk\@empty%
    #1%
  \else%
    % will already have a trailing '!'; don't add another
    \@idxhat@tail#2||%
  \fi%
}


%%
% Hyphenation
%
\hyphenation{Concept-One}
