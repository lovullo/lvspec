% LoVullo rater specification class
%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{raterspec}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{lvspec}}
\ProcessOptions\relax

% we're an extension of the base lvspec
\LoadClass[insuranceterms]{lvspec}

%%
% Default package includes
%
% Note that these are not all the packages that are available; see the
% raterspec/ directory in the lvspec repo
%
\RequirePackage{raterspec/param}
\RequirePackage{raterspec/class}
\RequirePackage{raterspec/question}
\RequirePackage{raterspec/rates}
\RequirePackage{raterspec/form}
\RequirePackage{raterspec/c1import}
\RequirePackage{lvflow}
\RequirePackage{longtable}
%\RequirePackage{premcalc}


%%
% Formatting
%

% we gots some big section numbers
\renewcommand\l@subsubsection{\@dottedtocline{3}{7em}{4.6em}}


%%
% Rater-specific specification additions
%
% This should be called before beginning the document environment
%
\def\@RaterProgramName#1{
  \gdef\@lvspec@pretitle{%
    #1 Supplier\\Specifications:\\
    \vspace{0.5em}%
  }
  \gdef\@lvspec@premarktitle{#1:\space}

  \abstract{%
    This document is a formal specification for the integration of
    \@title@short{} with the Dwelling Program of the Quote Server, Program
    UI and~ConceptOne. This document should contain all information
    necessary to complete a conforming implementation with minimal
    clarification and will serve as a reference for future development,
    including bug fixes and feature requests.
  }
}

\terminology{%
  \subsection{Rater Terminology}
  \input{raterspec/sec/rater-dfn}
}


%%
% Beginning of document
%
% The host environment is the same for all new systems
%

\let\@@madespec0

\def\@raterspec@mkhook#1#2#3#4{
  \expandafter\gdef\csname @raterspec@#1\endcsname{
    \PackageWarning{raterspec}{Missing #2!
      \MessageBreak Define using \expandafter\protect\csname#1\endcsname}%
    \incomplete
    \todo{No #2 have been defined.}%
  }
  % publicly accessible input macro
  \expandafter\gdef\csname#1in\endcsname##1{%
    \expandafter\gdef\csname @raterspec@#1\endcsname{%
      #3\input{##1}#4%
    }%
  }
  % publicly accessible output macro
  \expandafter\gdef\csname#1out\endcsname{%
    \csname @raterspec@#1\endcsname
  }
}

\def\makespec{
  \ifx\@@madespec1%
    \PackageError{raterspec}{Duplicate call to \protect\makespec}
  \fi

  \global\let\@@madespec1
  \input{raterspec/parts}
}

\AtEndDocument{
  \ifx\@@madespec0
    \PackageError{raterspec}{\protect\makespec\space was not called}
  \fi
}


%%
% Document hooks
%%

\@raterspec@mkhook{inputtypes}{input types}
  {%
    % can't really include a sigline here because approval would be global
    \pnumoff
      Parameter types in this section are common to the \@title@short\ program.
    \pnumon
    \index{parameter type|(}%
  }
  {\index{parameter type|)}}

\@raterspec@mkhook{inputparams}{input parameters}
  {}
  {}

\@raterspec@mkhook{dataclass}{data classifications}
  {}
  {}

\@raterspec@mkhook{premcalc}{premium calculations}
  {}
  {}

\@raterspec@mkhook{forms}{forms}
  {}
  {}

\@raterspec@mkhook{coneimport}{c1 import details}
  {}
  {}

\@raterspec@mkhook{proguisteps}{program ui steps}
  {}
  {}



%%
% Code generation
%
% Right now the code generation is tightly coupled with the packages that it
% is applicable to; they need to be refactored and hooks added
\newwrite\@@codegen
\immediate\openout\@@codegen=gen.xml

\def\@codegen{%
  \begingroup
    % prepare common cases for plain-text output
    \def\sref##1{the specification}%
    \def~{ }%
    \def\emph{}%
    \def\nobreakspace{ }%
    \def\${}%
    \@do@codegen
}
\def\@do@codegen#1{%
    \immediate\write\@@codegen{#1}%
  \endgroup
}


%%
% Misc
%

\def\@firstchar #1#2||{#1}
\def\@secondchar #1#2#3||{#2}
\def\@ifnumeric#1{{%
  \edef\@@chk{\@firstchar#1||}%
  % determine if this is a number
  \def\@@result{0}%
  % strip any negative sign
  \ifnum\expandafter`\@@chk=`-
    \edef\@@chk{\@secondchar#1--||}%
  \fi
  % perform number check
  \ifnum\expandafter`\@@chk<`0\else
    \ifnum\expandafter`\@@chk>`9\else
      % is a number
      \def\@@result{1}%
    \fi
  \fi
  % use the result to output a conditional that will match a closing \fi
  \aftergroup\ifnum
  \expandafter\aftergroup\@@result
  \aftergroup=%
  \aftergroup1%
  \aftergroup\relax
}}


\def\beginundersletter{%
  \begingroup% ended by \@dotypedef
  \catcode`\_=11\relax
}
\def\endundersletter{%
  \endgroup
}

