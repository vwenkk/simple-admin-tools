package {{.modelNameLowerCase}}

import (
	"context"
	"net/http"

    "{{.projectPackage}}/internal/svc"
	"{{.projectPackage}}/internal/types"
	"{{.rpcPackage}}"

	"{{.projectPackage}}/pkg/i18n"
	"github.com/zeromicro/go-zero/core/logx"
)

type Get{{.modelName}}ListLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
	lang   string
}

func NewGet{{.modelName}}ListLogic(r *http.Request, svcCtx *svc.ServiceContext) *Get{{.modelName}}ListLogic {
	return &Get{{.modelName}}ListLogic{
		Logger: logx.WithContext(r.Context()),
		ctx:    r.Context(),
		svcCtx: svcCtx,
		lang:   r.Header.Get("Accept-Language"),
	}
}

func (l *Get{{.modelName}}ListLogic) Get{{.modelName}}List(req *types.{{.modelName}}ListReq) (resp *types.{{.modelName}}ListResp, err error) {
	data, err := l.svcCtx.{{.rpcName}}Rpc.Get{{.modelName}}List(l.ctx,
		&{{.rpcPbPackageName}}.{{.modelName}}ListReq{
			Page:        req.Page,
			PageSize:    req.PageSize,{{.searchKeys}}
		})
	if err != nil {
		return nil, err
	}
	resp = &types.{{.modelName}}ListResp{}
	resp.Msg = l.svcCtx.Trans.Trans(l.lang, i18n.Success)
	resp.Data.Total = data.GetTotal()

	for _, v := range data.Data {
		resp.Data.Data = append(resp.Data.Data,
			types.{{.modelName}}Info{
				Base{{if .useUUID}}UUID{{end}}Info: types.Base{{if .useUUID}}UUID{{end}}Info{
					Id:        v.Id,
					CreatedAt: v.CreatedAt,
					UpdatedAt: v.UpdatedAt,
				},{{.setLogic}}
			})
	}
	return resp, nil
}
