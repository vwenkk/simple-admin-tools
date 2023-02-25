package {{.packageName}}

import (
	"context"

    "{{.projectPath}}/pkg/ent/{{.modelNameLowerCase}}"
	"{{.projectPath}}/pkg/ent/predicate"
    "{{.projectPath}}/rpc/internal/svc"
    "{{.projectPath}}/rpc/types/{{.projectName}}"

    "{{.projectPath}}/pkg/i18n"
    "{{.projectPath}}/pkg/statuserr"
    "github.com/zeromicro/go-zero/core/logx"
)

type Get{{.modelName}}ListLogic struct {
	ctx    context.Context
	svcCtx *svc.ServiceContext
	logx.Logger
}

func NewGet{{.modelName}}ListLogic(ctx context.Context, svcCtx *svc.ServiceContext) *Get{{.modelName}}ListLogic {
	return &Get{{.modelName}}ListLogic{
		ctx:    ctx,
		svcCtx: svcCtx,
		Logger: logx.WithContext(ctx),
	}
}

func (l *Get{{.modelName}}ListLogic) Get{{.modelName}}List(in *{{.projectName}}.{{.modelName}}ListReq) (*{{.projectName}}.{{.modelName}}ListResp, error) {
{{.predicateData}}

	if err != nil {
		logx.Error(err.Error())
		return nil, statuserr.NewInternalError(i18n.DatabaseError)
	}

	resp := &{{.projectName}}.{{.modelName}}ListResp{}
	resp.Total = result.PageDetails.Total

	for _, v := range result.List {
		resp.Data = append(resp.Data, &{{.projectName}}.{{.modelName}}Info{
			Id:          v.ID{{if .useUUID}}.String(){{end}},
			CreatedAt:   v.CreatedAt.UnixMilli(),
			UpdatedAt:   v.UpdatedAt.UnixMilli(),
{{.listData}}
		})
	}

	return resp, nil
}
