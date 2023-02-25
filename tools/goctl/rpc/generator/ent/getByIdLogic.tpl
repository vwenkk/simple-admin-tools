package {{.packageName}}

import (
	"context"

	"{{.projectPath}}/pkg/ent"
	"{{.projectPath}}/rpc/internal/svc"
    "{{.projectPath}}/rpc/types/{{.projectName}}"

	"{{.projectPath}}/pkg/i18n"
	"{{.projectPath}}/pkg/msg/logmsg"
	"{{.projectPath}}/pkg/statuserr"
{{if .useUUID}}    "{{.projectPath}}/pkg/uuidx"
{{end}}	"github.com/zeromicro/go-zero/core/logx"
)

type Get{{.modelName}}ByIdLogic struct {
	ctx    context.Context
	svcCtx *svc.ServiceContext
	logx.Logger
}

func NewGet{{.modelName}}ByIdLogic(ctx context.Context, svcCtx *svc.ServiceContext) *Get{{.modelName}}ByIdLogic {
	return &Get{{.modelName}}ByIdLogic{
		ctx:    ctx,
		svcCtx: svcCtx,
		Logger: logx.WithContext(ctx),
	}
}

func (l *Get{{.modelName}}ByIdLogic) Get{{.modelName}}ById(in *{{.projectName}}.{{if .useUUID}}UU{{end}}IDReq) (*{{.projectName}}.{{.modelName}}Info, error) {
	result, err := l.svcCtx.DB.{{.modelName}}.Get(l.ctx, {{if .useUUID}}uuidx.ParseUUIDString({{end}}in.Id{{if .useUUID}}){{end}})
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

	return &{{.projectName}}.{{.modelName}}Info{
		Id:          result.ID{{if .useUUID}}.String(){{end}},
		CreatedAt:   result.CreatedAt.UnixMilli(),
		UpdatedAt:   result.UpdatedAt.UnixMilli(),
{{.listData}}
	}, nil
}

