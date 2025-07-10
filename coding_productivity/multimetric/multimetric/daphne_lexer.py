# daphne_lexer.py
from pygments.lexer import RegexLexer
from pygments.token import Comment, Keyword, Name, Operator, Number, String, Text, Punctuation

class DaphneDSLLexer(RegexLexer):
    name = "DaphneDSL"
    aliases = ["daphnedsl"]
    filenames = ["*.daph"]

    tokens = {
        'root': [
            # Comments
            (r'//.*$', Comment.Single),
            (r'#.*$', Comment.Single),

            # Keywords / built-ins
            (r'\b(for|in|print|readMatrix|seq|aggMax|max|min|sum|fill|floor|t|as\.f64|as\.si64|as\.scalar|now|nrow|ncol|rand|cbind|rbind)\b', Keyword),

            # Numbers
            (r'\b\d+\.\d+\b', Number.Float),
            (r'\b\d+\b', Number.Integer),

            # Operators
            (r'[\+\-\*/=<>!@^]+', Operator),

            # Function names
            (r'\b[A-Za-z_]\w*(?=\()', Name.Function),

            # Variables
            (r'\b[A-Za-z_]\w*\b', Name),

            # List-style literals like [1.0]
            (r'\[[^\]]*\]', String),  # treat as literal strings for now

            # Punctuation
            (r'[{}\[\]();,:]', Punctuation),

            # Whitespace
            (r'\s+', Text),
        ]
    }
