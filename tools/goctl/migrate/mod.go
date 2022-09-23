package migrate

import (
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/zeromicro/go-zero/core/stringx"
	"github.com/zeromicro/go-zero/tools/goctl/rpc/execx"
	"github.com/zeromicro/go-zero/tools/goctl/util/console"
	"github.com/zeromicro/go-zero/tools/goctl/util/ctx"
)

const (
	deprecatedGoZeroMod = "github.com/tal-tech/go-zero"
	deprecatedBuilderx  = "github.com/tal-tech/go-zero/tools/goctl/model/sql/builderx"
	replacementBuilderx = "github.com/zeromicro/go-zero/core/stores/builder"
	goZeroMod           = "github.com/zeromicro/go-zero"
	adminTool           = "github.com/suyuan32/simple-admin-tools"
)

var errInvalidGoMod = errors.New("it's only working for go module")

func editMod(zeroVersion, toolVersion string, verbose bool) error {
	wd, err := os.Getwd()
	if err != nil {
		return err
	}

	isGoMod, _ := ctx.IsGoMod(wd)
	if !isGoMod {
		return nil
	}

	latest, err := getLatest(goZeroMod, verbose)
	if err != nil {
		return err
	}

	if !stringx.Contains(latest, zeroVersion) {
		return fmt.Errorf("release version %q is not found", zeroVersion)
	}

	mod := fmt.Sprintf("%s@%s", goZeroMod, zeroVersion)
	err = removeRequire(deprecatedGoZeroMod, verbose)
	if err != nil {
		return err
	}

	err = addRequire(mod, verbose)
	if err != nil {
		return err
	}

	// add replace
	mod = fmt.Sprintf("%s@%s=%s@%s", goZeroMod, zeroVersion, adminTool, toolVersion)

	err = addReplace(mod, verbose)
	if err != nil {
		return err
	}

	return nil
}

func addRequire(mod string, verbose bool) error {
	if verbose {
		console.Info("adding require %s ...", mod)
		time.Sleep(200 * time.Millisecond)
	}
	wd, err := os.Getwd()
	if err != nil {
		return err
	}

	isGoMod, _ := ctx.IsGoMod(wd)
	if !isGoMod {
		return errInvalidGoMod
	}

	_, err = execx.Run("go mod edit -require "+mod, wd)
	return err
}

func addReplace(mod string, verbose bool) error {
	if verbose {
		console.Info("adding replace %s ...", mod)
		time.Sleep(200 * time.Millisecond)
	}
	wd, err := os.Getwd()
	if err != nil {
		return err
	}

	isGoMod, _ := ctx.IsGoMod(wd)
	if !isGoMod {
		return errInvalidGoMod
	}

	_, err = execx.Run("go mod edit -replace "+mod, wd)
	return err
}

func removeRequire(mod string, verbose bool) error {
	if verbose {
		console.Info("remove require %s ...", mod)
		time.Sleep(200 * time.Millisecond)
	}
	wd, err := os.Getwd()
	if err != nil {
		return err
	}
	_, err = execx.Run("go mod edit -droprequire "+mod, wd)
	return err
}

func tidy(verbose bool) error {
	if verbose {
		console.Info("go mod tidy ...")
		time.Sleep(200 * time.Millisecond)
	}
	wd, err := os.Getwd()
	if err != nil {
		return err
	}
	isGoMod, _ := ctx.IsGoMod(wd)
	if !isGoMod {
		return nil
	}

	_, err = execx.Run("go mod tidy", wd)
	return err
}
