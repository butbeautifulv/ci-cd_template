package fuzzdemo

import (
	"testing"
	"unicode/utf8"
)

func FuzzParse(f *testing.F) {
	f.Add([]byte("hello"))
	f.Fuzz(func(t *testing.T, data []byte) {
		if len(data) == 0 {
			return
		}
		if !utf8.Valid(data) {
			return
		}
		_ = len(data)
	})
}
