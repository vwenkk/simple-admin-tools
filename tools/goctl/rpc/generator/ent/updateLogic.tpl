package {{.packageName}}

import (
	"context"
{{if .hasTime}}     "time"{{end}}

	"{{.projectPath}}/pkg/ent"
	"{{.projectPath}}/pkg/internal/svc"
    "{{.projectPath}}/rpc/types/{{.projectName}}"

    "{{.projectPath}}/pkg/i18n"
	"{{.projectPath}}/pkg/msg/logmsg"
	"{{.projectPath}}/pkg/statuserr"
{{if or .hasUUID .useUUID}}	"{{.projectPath}}/pkg/uuidx"{{end}}
	"github.com/zeromicro/go-zero/core/logx"
)

type Update{{.modelName}}Logic struct {
	ctx    context.Context
	svcCtx *svc.ServiceContext
	logx.Logger
}

func NewUpdate{{.modelName}}Logic(ctx context.Context, svcCtx *svc.ServiceContext) *Update{{.modelName}}Logic {
	return &Update{{.modelName}}Logic{
		ctx:    ctx,
		svcCtx: svcCtx,
		Logger: logx.WithContext(ctx),
	}
}

func (l *Update{{.modelName}}Logic) Update{{.modelName}}(in *{{.projectName}}.{{.modelName}}Info) (*{{.projectName}}.BaseResp, error) {
    err := l.svcCtx.DB.{{.modelName}}.UpdateOneID({{if .useUUID}}uuidx.ParseUUIDString({{end}}in.Id){{if .useUUID}}){{end}}.
{{.setLogic}}

    if err != nil {
        switch {
        case ent.IsNotFound(err):
            logx.Errorw(err.Error(), logx.Field("detail", in))
            return nil, statuserr.NewInvalidArgumentError(i18n.TargetNotFound)
        case ent.IsConstraintError(err):
            logx.Errorw(err.Error(), logx.Field("detail", in))
            return nil, statuserr.NewInvalidArgumentError(i18n.UpdateFailed)
        default:
            logx.Errorw(logmsg.DatabaseError, logx.Field("detail", err.Error()))
            return nil, statuserr.NewInternalError(i18n.DatabaseError)
        }
    }

    return &{{.projectName}}.BaseResp{Msg: i18n.UpdateSuccess}, nil
}
