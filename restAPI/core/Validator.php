<?php
// ============================================================
// Validator – lightweight input validation
// ============================================================

class Validator
{
    private array $errors = [];

    /**
     * Validate $data against $rules.
     *
     * Rules are pipe-separated strings, e.g.:
     *   'required|string|max:200'
     *   'required|numeric|min:0'
     *   'nullable|email'
     *   'required|in:pending,accepted,rejected,returned'
     */
    public function validate(array $data, array $rules): bool
    {
        $this->errors = [];

        foreach ($rules as $field => $ruleStr) {
            $fieldRules = explode('|', $ruleStr);
            $value      = $data[$field] ?? null;
            $nullable   = in_array('nullable', $fieldRules, true);

            foreach ($fieldRules as $rule) {
                if ($rule === 'nullable') continue;

                [$ruleName, $ruleParam] = array_pad(explode(':', $rule, 2), 2, null);

                // Skip further rules if nullable and value is absent/null
                if ($nullable && ($value === null || $value === '')) {
                    break;
                }

                $this->applyRule($field, $value, $ruleName, $ruleParam, $data, $fieldRules);
            }
        }

        return empty($this->errors);
    }

    public function errors(): array
    {
        return $this->errors;
    }

    /** Validate and abort with 422 on failure */
    public function validateOrFail(array $data, array $rules): void
    {
        if (!$this->validate($data, $rules)) {
            Response::unprocessable($this->errors);
        }
    }

    // ── Rule engine ───────────────────────────────────────────
    private function applyRule(
        string  $field,
        mixed   $value,
        string  $rule,
        ?string $param,
        array   $data,
        array   $fieldRules = []
    ): void {
        // Helper: should min/max compare by string length?
        $isStringField  = in_array('string',  $fieldRules, true);
        $isNumericField = in_array('numeric', $fieldRules, true)
                       || in_array('integer', $fieldRules, true);
        switch ($rule) {
            case 'required':
                if ($value === null || $value === '') {
                    $this->errors[$field][] = "The $field field is required.";
                }
                break;

            case 'string':
                if ($value !== null && !is_string($value)) {
                    $this->errors[$field][] = "The $field must be a string.";
                }
                break;

            case 'numeric':
                if ($value !== null && !is_numeric($value)) {
                    $this->errors[$field][] = "The $field must be numeric.";
                }
                break;

            case 'integer':
                if ($value !== null && filter_var($value, FILTER_VALIDATE_INT) === false) {
                    $this->errors[$field][] = "The $field must be an integer.";
                }
                break;

            case 'boolean':
                if ($value !== null && !in_array($value, [true, false, 0, 1, '0', '1'], true)) {
                    $this->errors[$field][] = "The $field must be a boolean.";
                }
                break;

            case 'email':
                if ($value !== null && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $this->errors[$field][] = "The $field must be a valid email.";
                }
                break;

            case 'min':
                if ($value !== null) {
                    if ($isStringField) {
                        // String length check
                        if (strlen((string)$value) < (int)$param) {
                            $this->errors[$field][] = "The $field must be at least $param characters.";
                        }
                    } elseif ($isNumericField && is_numeric($value)) {
                        // Numeric comparison
                        if ((float)$value < (float)$param) {
                            $this->errors[$field][] = "The $field must be at least $param.";
                        }
                    } elseif (is_numeric($value) && !is_string($value)) {
                        // PHP int/float (not a string)
                        if ($value < (float)$param) {
                            $this->errors[$field][] = "The $field must be at least $param.";
                        }
                    } elseif (is_string($value)) {
                        if (strlen($value) < (int)$param) {
                            $this->errors[$field][] = "The $field must be at least $param characters.";
                        }
                    }
                }
                break;

            case 'max':
                if ($value !== null) {
                    if ($isStringField) {
                        // String length check
                        if (strlen((string)$value) > (int)$param) {
                            $this->errors[$field][] = "The $field must not exceed $param characters.";
                        }
                    } elseif ($isNumericField && is_numeric($value)) {
                        // Numeric comparison
                        if ((float)$value > (float)$param) {
                            $this->errors[$field][] = "The $field must not exceed $param.";
                        }
                    } elseif (is_numeric($value) && !is_string($value)) {
                        // PHP int/float (not a string)
                        if ($value > (float)$param) {
                            $this->errors[$field][] = "The $field must not exceed $param.";
                        }
                    } elseif (is_string($value)) {
                        if (strlen($value) > (int)$param) {
                            $this->errors[$field][] = "The $field must not exceed $param characters.";
                        }
                    }
                }
                break;

            case 'in':
                $allowed = explode(',', $param ?? '');
                if ($value !== null && !in_array((string)$value, $allowed, true)) {
                    $this->errors[$field][] = "The $field must be one of: " . implode(', ', $allowed) . '.';
                }
                break;

            case 'array':
                if ($value !== null && !is_array($value)) {
                    $this->errors[$field][] = "The $field must be an array.";
                }
                break;

            case 'date':
                if ($value !== null && strtotime($value) === false) {
                    $this->errors[$field][] = "The $field must be a valid date.";
                }
                break;

            case 'confirmed':
                $confirmField = $field . '_confirmation';
                if ($value !== ($data[$confirmField] ?? null)) {
                    $this->errors[$field][] = "The $field confirmation does not match.";
                }
                break;
        }
    }
}
