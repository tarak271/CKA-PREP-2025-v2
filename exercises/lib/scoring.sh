#!/bin/bash
# Exam scoring helpers — percentage always uses ALL exam marks (unattempted = 0).

if [[ -z "${CKA_SCORING_LIB_LOADED:-}" ]]; then
  CKA_SCORING_LIB_LOADED=1

  declare -A QUESTION_MAX_MARKS=(
    [q01]=4
    [q02]=5
    [q03]=3
    [q04]=5
    [q05]=4
    [q06]=2
    [q07]=2
    [q08]=3
    [q09]=6
    [q10]=2
    [q11]=2
    [q12]=2
    [q13]=2
    [q14]=3
    [q15]=2
    [q16]=3
    [q17]=3
  )

  compute_total_exam_marks() {
    local entry qid sum=0
    for entry in "${QUESTION_ORDER[@]}"; do
      IFS=':' read -r qid _ _ <<< "$entry"
      sum=$((sum + ${QUESTION_MAX_MARKS[$qid]:-0}))
    done
    echo "$sum"
  }

  question_was_attempted() {
    local qid="$1"
    local scores_file="$2"
    [[ -f "$scores_file" ]] && grep -q "^${qid}	" "$scores_file" 2>/dev/null
  }

  get_question_earned() {
    local qid="$1"
    local scores_file="$2"
    local earned=0

    if [[ -f "$scores_file" ]]; then
      while IFS=$'\t' read -r fqid _ _ mark; do
        [[ "$fqid" == "$qid" ]] && earned=$((earned + mark))
      done < "$scores_file"
    fi
    echo "$earned"
  }

  compute_exam_score() {
    local scores_file="$1"
    local entry qid earned=0 attempted=0 total_marks

    total_marks=$(compute_total_exam_marks)

    for entry in "${QUESTION_ORDER[@]}"; do
      IFS=':' read -r qid _ _ <<< "$entry"
      earned=$((earned + $(get_question_earned "$qid" "$scores_file")))
      if question_was_attempted "$qid" "$scores_file"; then
        attempted=$((attempted + 1))
      fi
    done

    echo "${earned} ${total_marks} ${attempted}"
  }

  show_score_summary() {
    local scores_file="${1:-$SCORES_FILE}"
    local earned total_marks attempted pct unattempted_marks=0

    read -r earned total_marks attempted <<< "$(compute_exam_score "$scores_file")"

    local entry qid q_max
    for entry in "${QUESTION_ORDER[@]}"; do
      IFS=':' read -r qid _ _ <<< "$entry"
      if ! question_was_attempted "$qid" "$scores_file"; then
        q_max=${QUESTION_MAX_MARKS[$qid]:-0}
        unattempted_marks=$((unattempted_marks + q_max))
      fi
    done

    echo -e "${BOLD}Score:${NC} ${earned}/${total_marks} marks"
    echo -e "${BOLD}Questions attempted:${NC} ${attempted}/${TOTAL_QUESTIONS}"
    if [[ $attempted -lt $TOTAL_QUESTIONS ]]; then
      echo -e "${BOLD}Unattempted marks:${NC} ${unattempted_marks} (counted as 0)"
    fi
    if [[ $total_marks -gt 0 ]]; then
      pct=$((earned * 100 / total_marks))
      echo -e "${BOLD}Percentage:${NC} ${pct}% (of ${total_marks} total exam marks)"
    fi
  }

  show_final_breakdown() {
    local scores_file="${1:-$SCORES_FILE}"
    local entry qid q_earned q_max attempted

    echo -e "${BOLD}Breakdown by question:${NC}"
    echo "────────────────────────────────────────"

    for entry in "${QUESTION_ORDER[@]}"; do
      IFS=':' read -r qid _ _ <<< "$entry"
      q_max=${QUESTION_MAX_MARKS[$qid]:-0}
      q_earned=$(get_question_earned "$qid" "$scores_file")

      if question_was_attempted "$qid" "$scores_file"; then
        printf "  %-6s %2d/%2d\n" "$qid" "$q_earned" "$q_max"
      else
        printf "  %-6s %2d/%2d  (not attempted)\n" "$qid" 0 "$q_max"
      fi
    done
  }
fi
