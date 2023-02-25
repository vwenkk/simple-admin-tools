package {{.packageName}}

import (
	"context"

    "{{.projectPath}}/pkg/ent"
    "{{.projectPath}}/pkg/ent/{{.modelNameLowerCase}}"
    "{{.projectPath}}/rpc/internal/svc"
    "{{.projectPath}}/rpc/types/{{.projectName}}"

    "{{.projectPath}}/pkg/i18n"
    "{{.projectPath}}/pkg/msg/logmsg"
    "{{.projectPath}}/pkg/statuserr"
{{if .useUUID}}    "{{.projectPath}}/pkg/uuidx"
{{end}}    "github.com/zeromicro/go-zero/core/logx"
)

type Delete{{.modelName}}Logic struct {
	ctx    context.Context
	svcCtx *svc.ServiceContext
	logx.Logger
}

func NewDelete{{.modelName}}Logic(ctx context.Context, svcCtx *svc.ServiceContext) *Delete{{.modelName}}Logic {
	return &Delete{{.modelName}}Logic{
		ctx:    ctx,
		svcCtx: svcCtx,
		Logger: logx.WithContext(ctx),
	}
}

func (l *Delete{{.modelName}}Logic) Delete{{.modelName}}(in *{{.projectName}}.{{if .useUUID}}UU{{end}}IDsReq) (*{{.projectName}}.BaseResp, error) {
	_, err := l.svcCtx.DB.{{.modelName}}.Delete().Where({{.modelNameLowerCase}}.IDIn({{if .useUUID}}uuidx.ParseUUIDSlice({{end}}in.Ids{{if .useUUID}}){{end}}...)).Exec(l.ctx)

    if err != nil {
        switch {
        case ent.IsNotFound(err):
            logx.Errorw(err.Error(), logx.Field("detail", in))
            return nil, statuserr.NewInvalidArgumentError(i18n.TargetNotFound)
        default:
            logx.Errorw(logmsg.DatabaseError, logx.Field("detail", err.Error()))
            return nil, statuserr.NewInternalError(i18n.DatabaseError)
        }
    }

    return &{{.projectName}}.BaseResp{Msg: i18n.DeleteSuccess}, nil
}
