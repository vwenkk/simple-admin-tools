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

type Get{{.modelName}}ByIdLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
	lang   string
}

func NewGet{{.modelName}}ByIdLogic(r *http.Request, svcCtx *svc.ServiceContext) *Get{{.modelName}}ByIdLogic {
	return &Get{{.modelName}}ByIdLogic{
		Logger: logx.WithContext(r.Context()),
		ctx:    r.Context(),
		svcCtx: svcCtx,
		lang:   r.Header.Get("Accept-Language"),
	}
}

func (l *Get{{.modelName}}ByIdLogic) Get{{.modelName}}ById(req *types.{{if .useUUID}}UU{{end}}IDReq) (resp *types.{{.modelName}}InfoResp, err error) {
	data, err := l.svcCtx.{{.rpcName}}Rpc.Get{{.modelName}}ById(l.ctx, &{{.rpcPbPackageName}}.{{if .useUUID}}UU{{end}}IDReq{Id: req.Id})
	if err != nil {
		return nil, err
	}

	return &types.{{.modelName}}InfoResp{
		BaseDataInfo: types.BaseDataInfo{
			Code: 0,
			Msg:  l.svcCtx.Trans.Trans(l.lang, i18n.Success),
		},
		Data: types.{{.modelName}}Info{
            Base{{if .useUUID}}UUID{{end}}Info: types.Base{{if .useUUID}}UUID{{end}}Info{
                Id:        data.Id,
                CreatedAt: data.CreatedAt,
                UpdatedAt: data.UpdatedAt,
            },{{.setLogic}}
		},
	}, nil
}

