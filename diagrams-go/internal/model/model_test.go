package model

import "testing"

func TestValidate(t *testing.T) {
	if err := Validate(); err != nil {
		t.Fatal(err)
	}
}

func TestIterThreatsNonEmpty(t *testing.T) {
	rows := IterThreats()
	if len(rows) < 10 {
		t.Fatalf("expected many threats, got %d", len(rows))
	}
	if rows[0].ID != "T-S-001" {
		t.Fatalf("first id = %q", rows[0].ID)
	}
}
