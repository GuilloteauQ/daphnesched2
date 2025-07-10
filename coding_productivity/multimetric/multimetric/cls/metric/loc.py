# SPDX-FileCopyrightText: 2023 Konrad Weihmann
# SPDX-License-Identifier: Zlib
from multimetric.cls.base import MetricBase


class MetricBaseLOC(MetricBase):
    METRIC_LOC = "sloc"

    _needles = [
        "Token.Text",
        "Token.Comment.Preproc",
        "Token.Text.Whitespace",
    ]

    def __init__(self, args, **kwargs):
        super().__init__(args, **kwargs)
        self._previous_token = (None, None)

    def parse_tokens(self, language, tokens):
        super().parse_tokens(language, [])
        self._metrics[MetricBaseLOC.METRIC_LOC] = 0

        # Comment tokens to exclude from SLOC
        exclude_types = [
            "Token.Comment.Single",
            "Token.Comment.Multiline",
        ]

        # for x in tokens:
        #     if self._previous_token != x:
        #         if x[1].strip(' ').endswith('\n'):
        #             self._metrics[MetricBaseLOC.METRIC_LOC] += 1
        #     self._previous_token = x

        # Adapted to count only SLOC
        for x in tokens:
            if self._previous_token != x:
                # consider if the token has a new line at the end
                if x[1].strip(' ').endswith('\n'):
                    # Exclude if the previous token had a newline as well
                    if not self._previous_token[1].strip(' ').endswith('\n'):
                        # Exclude those that are comments either x or the previous
                        if str(x[0]) not in exclude_types and str(self._previous_token[0]) not in exclude_types:\
                            # for debugging purposes
                            # print(x, self._previous_token)
                            self._metrics[MetricBaseLOC.METRIC_LOC] += 1  
            self._previous_token = x      

        self._metrics[MetricBaseLOC.METRIC_LOC] = max(self._metrics[MetricBaseLOC.METRIC_LOC], 1)
        self._internalstore["sloc"] = self._metrics[MetricBaseLOC.METRIC_LOC]

    def get_results_global(self, value_stores):
        _sum = sum([x["sloc"] for x in self._get_all_matching_store_objects(value_stores)])
        return {MetricBaseLOC.METRIC_LOC: _sum}
