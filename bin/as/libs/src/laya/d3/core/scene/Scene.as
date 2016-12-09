package laya.d3.core.scene {
	import laya.d3.core.BaseCamera;
	import laya.d3.core.Camera;
	import laya.d3.core.render.RenderState;
	import laya.d3.math.Matrix4x4;
	import laya.d3.math.Vector3;
	import laya.d3.resource.RenderTexture;
	import laya.webgl.WebGL;
	import laya.webgl.WebGLContext;
	
	/**
	 * <code>Scene</code> 类用于实现普通场景。
	 */
	public class Scene extends BaseScene {
		/**
		 * 创建一个 <code>Scene</code> 实例。
		 */
		public function Scene() {
			super();
		}
		
		private function _renderCamera(gl:WebGLContext, state:RenderState, camera:Camera):void {
			_prepareRenderToRenderState(camera, state);//TODO:优化多摄像机ShaderValue和ShaderDefine
			beforeRender(state);//渲染之前
			var renderTarget:RenderTexture = camera.renderTarget;
			if (renderTarget) {
				renderTarget.start();
				Matrix4x4.multiply(_invertYScaleMatrix, camera.projectionMatrix, _invertYProjectionMatrix);
				Matrix4x4.multiply(_invertYScaleMatrix, camera.projectionViewMatrix, _invertYProjectionViewMatrix);
				state.projectionMatrix = _invertYProjectionMatrix;
				state.projectionViewMatrix = _invertYProjectionViewMatrix;
			} else {
				state.projectionMatrix = camera.projectionMatrix;
				state.projectionViewMatrix = camera.projectionViewMatrix;
			}
			state.viewMatrix = camera.viewMatrix;
			state.viewport = camera.viewport;
			_preRenderScene(gl, state);
			_clear(gl, state);
			_renderScene(gl, state);
			lateRender(state);//渲染之后
			_endRenderToRenderState(state);
			(renderTarget) && (renderTarget.end());
		}
		
		/**
		 * @private
		 */
		override public function renderSubmit():int {
			var gl:WebGLContext = WebGL.mainContext;
			_set3DRenderConfig(gl);//设置3D配置
			for (var i:int = 0, n:int = _cameraPool.length; i < n; i++) {
				var camera:Camera = _cameraPool[i] as Camera;
				(camera.enable) && (_renderCamera(gl, _renderState, camera));
			}
			_set2DRenderConfig(gl);//设置2D配置
			return 1;
		}
	}
}